with m as (select id dup_id, min(id) over (partition by supplier_id, file_name) keep_id
           from prices.import_runs where status = 'ok')
update prices.supplier_items si set last_run_id = m.keep_id
from m where si.last_run_id = m.dup_id and m.dup_id <> m.keep_id;

with m as (select id dup_id, min(id) over (partition by supplier_id, file_name) keep_id
           from prices.import_runs where status = 'ok')
update prices.supplier_items si set first_run_id = m.keep_id
from m where si.first_run_id = m.dup_id and m.dup_id <> m.keep_id;

with m as (select id dup_id, min(id) over (partition by supplier_id, file_name) keep_id
           from prices.import_runs where status = 'ok')
delete from prices.import_runs r
using m where r.id = m.dup_id and m.dup_id <> m.keep_id;

select r.id, s.label, r.file_name, r.price_date,
       (select count(*) from prices.price_snapshots p where p.import_run_id = r.id) as prices
from prices.import_runs r join prices.suppliers s on s.id = r.supplier_id
order by r.id;
