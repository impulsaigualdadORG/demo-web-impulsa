-- Ejecuta este archivo en el editor SQL de un proyecto Supabase nuevo.
-- Cambia 6 por 5 en lottery_settings si quieres revelar con cinco papeletas.

create table if not exists public.lottery_settings (
  id integer primary key default 1 check (id = 1),
  min_participants integer not null default 6 check (min_participants between 5 and 100)
);
insert into public.lottery_settings (id, min_participants)
values (1, 6) on conflict (id) do nothing;

create table if not exists public.lottery_ballots (
  participant_id uuid primary key,
  choices smallint[] not null,
  created_at timestamptz not null default now(),
  constraint five_valid_choices check (
    array_length(choices, 1) = 5 and array_ndims(choices) = 1
    and choices <@ array[0,1,2]::smallint[]
  )
);

alter table public.lottery_settings enable row level security;
alter table public.lottery_ballots enable row level security;
revoke all on public.lottery_settings from public, anon, authenticated;
revoke all on public.lottery_ballots from public, anon, authenticated;

-- Esta función puede insertar con privilegios del propietario, sin dar acceso
-- directo a la tabla. Un UUID por navegador evita duplicados accidentales.
create or replace function public.submit_lottery_ballot(
  p_participant uuid,
  p_choices smallint[]
) returns jsonb
language plpgsql security definer set search_path = ''
as $$
declare v_inserted integer; v_threshold integer; v_count integer;
begin
  if p_participant is null or p_choices is null
     or array_ndims(p_choices) <> 1 or array_length(p_choices, 1) <> 5
     or not (p_choices <@ array[0,1,2]::smallint[]) then
    raise exception 'Papeleta no válida';
  end if;
  -- Serializa los envíos; una vez alcanzado el mínimo no admite más votos.
  select min_participants into v_threshold
    from public.lottery_settings where id=1 for update;
  if v_threshold is null then raise exception 'Configura lottery_settings'; end if;
  select count(*) into v_count from public.lottery_ballots;
  if v_count >= v_threshold then
    return pg_catalog.jsonb_build_object('accepted',false,'closed',true);
  end if;
  insert into public.lottery_ballots (participant_id,choices)
  values (p_participant,p_choices)
  on conflict (participant_id) do nothing;
  get diagnostics v_inserted = row_count;
  return pg_catalog.jsonb_build_object('accepted',v_inserted=1);
end;
$$;

-- Antes del umbral devuelve exclusivamente el recuento. Después calcula
-- número y suplentes en el servidor. Empates: gana la primera opción.
create or replace function public.lottery_status() returns jsonb
language plpgsql security definer set search_path = ''
as $$
declare
  v_count integer;
  v_threshold integer;
  v_map text[][] := array[
    array['2','5','8'],array['1','4','7'],array['0','3','9'],
    array['2','6','8'],array['1','5','7']
  ];
  v_digits text[] := array['','','','',''];
  v_alt text[] := array['','','','',''];
  v_winner integer;
  v_second integer;
  v_number text;
  v_alternatives jsonb := '[]'::jsonb;
  i integer;
begin
  select count(*) into v_count from public.lottery_ballots;
  select min_participants into v_threshold from public.lottery_settings where id=1;
  if v_threshold is null then raise exception 'Configura lottery_settings'; end if;
  if v_count < v_threshold then
    return pg_catalog.jsonb_build_object('count',v_count,'threshold',v_threshold,'revealed',false);
  end if;
  for i in 1..5 loop
    select j into v_winner from pg_catalog.generate_series(1,3) as j
      order by (select count(*) from public.lottery_ballots b where b.choices[i]=j-1) desc,j asc limit 1;
    select j into v_second from pg_catalog.generate_series(1,3) as j
      order by (select count(*) from public.lottery_ballots b where b.choices[i]=j-1) desc,j asc limit 1 offset 1;
    v_digits[i]:=v_map[i][v_winner];
    v_alt[i]:=v_map[i][v_second];
  end loop;
  v_number:=pg_catalog.array_to_string(v_digits,'');
  for i in 1..3 loop
    -- Cada alternativa sustituye una cifra por la segunda más votada.
    v_alternatives:=v_alternatives || pg_catalog.to_jsonb(
      pg_catalog.array_to_string(v_digits[1:i-1] || array[v_alt[i]] || v_digits[i+1:5],'')
    );
  end loop;
  return pg_catalog.jsonb_build_object('count',v_count,'threshold',v_threshold,
    'revealed',true,'number',v_number,'alternatives',v_alternatives);
end;
$$;

revoke execute on function public.submit_lottery_ballot(uuid,smallint[]) from public,anon,authenticated;
revoke execute on function public.lottery_status() from public,anon,authenticated;
grant execute on function public.submit_lottery_ballot(uuid,smallint[]) to anon;
grant execute on function public.lottery_status() to anon;
