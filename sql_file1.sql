use role SYSADMIN;
use warehouse MY_NEW_WAREHOUSE;
use schema cricket.clean;


-- first lets extract the elements from the innings array
select 
    m.info:match_type_number::int as match_type_number,
    m.innings
from cricket.raw.match_raw_tbl m
where match_type_number =1635;


select 
    m.info:match_type_number::int as match_type_number,
    i.value:team::text as team_name,
    i.*
from cricket.raw.match_raw_tbl m,
lateral flatten (input=>m.innings) i
where match_type_number =1635;


-- Each team has played multple Overs so lets extract that

select 
    m.info:match_type_number::int as match_type_number,
    i.value:team::text as team_name,
    -- i.*,
    o.value:over::int as over,
   d.value:bowler::text as bowler,
   d.value:batter::text as batter,
   d.value:non_striker::text as non_striker,
   d.value:runs.batter::text as runs,
   d.value:runs.extras::text as extras,
   d.value:runs.total::text as total,
from cricket.raw.match_raw_tbl m,
lateral flatten (input=>m.innings) i,
lateral flatten  (input=> i.value:overs) o, 
lateral flatten (input => o.value:deliveries) d
where match_type_number =1635;

-- This code is for debugging purpose
select m.stg_file_name,m.info:match_type_number::int as match_type_number
from cricket.raw.match_raw_tbl m
where match_type_number =1635;