use role SYSADMIN;
use warehouse MY_NEW_WAREHOUSE;
use schema cricket.clean;

-- step1
-- The meta column does not have any real domain value, and  it just caputures the JSON file version.
-- Since it is an object data type, here is how we select and extract each element.

-- extracting element from object data type
select
    meta['data_version']::text as data_version,
    meta['created']::date as created,
    meta['revision']::number as revision

    -- The code above does similar to the  lines of code above
        -- meta:data_version::text as data_version,
        -- meta:created::date as created,
        -- meta:revision::number as revision
from
cricket.raw.match_raw_tbl;


-- step2:
-- extracting elements from info column that is of variant data type 
-- it has lot of important information. Thus, we need to analyse them.
select 
        info:match_type_number:: int as match_type_number,
        info:match_type::text as match_type,
        info:season::text as season,
        info:team_type:: text as team_type,
        info:overs::text as overs,
        info:city::text as city,
        info:venue::text as venu
from 
        cricket.raw.match_raw_tbl;

-- select count(*) from cricket.raw.match_raw_tbl;
-- the code above displays 1884 rows
-- We observe from this data that the city column has some missing values while the venu is complete


select 
        info:match_type_number:: int as match_type_number,
        info:event.name::text as event_name,
        case
        when
        info:event.match_number::text is not null then info:event.match_number::text
        when
        info:event.stage::text is not null then info:event.stage::text
        else
        'NA'
        end as match_stage,
        info:dates[0]::date as event_date,
        date_part('year', info:dates[0]::date) as event_year,
        date_part('month', info:dates[0]::date) as event_month,
        date_part('day', info:dates[0]::date) as event_day,
        info:match_type::text as match_type,
        info:season::text as season,
        info:team_type::text as team_type,
        info:overs::text as overs,
        info:city::text as city,
        info:venue::text as venue,
        info:gender::text as gender,
        info:teams[0]::text as first_team,
        info:teams[1]::text as second_team,
        case
            when info:outcome.winner is not null then 'Result Declared'
            when info:outcome.result = 'tie' then 'Tie'
            when info:outcome.result = 'no result' then 'No Result'
            else info:outcome.result
        end as match_result,

        case
            when info:outcome.winner is not null then info:outcome.winner
            else 'NA'
            end as winner,

            info:toss.winner::text as toss_winner,
            initcap(info:toss.decision::text) as toss_decision
    from
    cricket.raw.match_raw_tbl;
    
 -- This query is used find the venue for a given match using its match_type_number       
     SELECT info:venue::text AS venue
     FROM cricket.raw.match_raw_tbl
     WHERE info:match_type_number::number = 3161;

    -- This query list all the match_type_numbers and orders the in ascending order 
    SELECT DISTINCT info:match_type_number::string AS match_type_number
    FROM cricket.raw.match_raw_tbl
    ORDER BY  match_type_number::int desc;
     -- ORDER BY  match_type_number::int desc;  --In descending order

 -- query for selecting the winners for a particular match    
    -- select info:outcome.winner::text as winner
    -- FROM cricket.raw.match_raw_tbl
    -- WHERE info:match_type_number::number = 31 and info:dates::date = "2008-05-10" ;

    -- querry to select teams that were tied in a matches and count the number of ties 
 select COUNT(*) AS tie_count 
     FROM   (SELECT DISTINCT info:match_type_number::string AS match_type_number, info:teams, info:dates
     FROM cricket.raw.match_raw_tbl
     where info:outcome.result = 'tie');

-- SELECT info
-- FROM cricket.raw.match_raw_tbl
-- LIMIT 10;

select innings[1]:overs[10].deliveries,
     FROM cricket.raw.match_raw_tbl
     WHERE info:match_type_number::number = 30;


select
    raw.info:match_type_number::int as match_type_number,
    raw.info:players,
    raw.info:teams
from cricket.raw.match_raw_tbl raw;


--The players and teams in a particular match(identified by the match_type_number)
select
    raw.info:match_type_number::int as match_type_number,
    raw.info:players,
    raw.info:teams
from cricket.raw.match_raw_tbl raw
where match_type_number = 1635;

-- Lets now see the flattened version of the above code for a better observability
select raw.info:match_type_number::int as match_type_number,
        -- p.* -- selects all the columns that are created by flattening the data
        p.key::text as country
        from cricket.raw.match_raw_tbl raw,
        lateral flatten (input => raw.info:players) p
        where match_type_number =1635;



select raw.info:match_type_number::int as match_type_number,
        -- p.* -- selects all the columns that are created by flattening the data
        p.key::text as country,
        team.*
        from cricket.raw.match_raw_tbl raw,
        lateral flatten (input => raw.info:players) p,
        lateral flatten (input => p.value)team
        where match_type_number =1635;


select raw.info:match_type_number::int as match_type_number,
        -- p.* -- selects all the columns that are created by flattening the data
        p.key::text as country,
        -- team.*
        team.value::text as player_name
        from cricket.raw.match_raw_tbl raw,
        lateral flatten (input => raw.info:players) p,
        lateral flatten (input => p.value)team
        where match_type_number =1635;


-- the belew query creates a table for players
create or replace table cricket.clean.player_clean_tbl as 
select raw.info:match_type_number::int as match_type_number,
        p.key::text as country,
        team.value::text as player_name,
        raw.stg_file_name,
        raw.stg_file_row_number,
        raw.stg_file_hashkey,
        raw.stg_modified_ts
        from cricket.raw.match_raw_tbl raw,
        lateral flatten (input => raw.info:players) p,
        lateral flatten (input => p.value)team;

-- lets see what the table looks like        
select * from cricket.clean.player_clean_tbl;

-- number of rows of the table created 
select count(*) from cricket.clean.player_clean_tbl;

-- now lets describe the table
desc table cricket.clean.player_clean_tbl;

-- so we observe by running the code above that all the columns of the table created
-- consist of null value.  But this should not be the case, so lets run the code below.

SELECT COUNT(*) AS null_count
FROM cricket.clean.player_clean_tbl
WHERE match_type_number IS NULL;

-- in the below lines fo code we are altering the table to mitigate for the null values
alter table cricket.clean.player_clean_tbl
modify column match_type_number set not null;

alter table cricket.clean.player_clean_tbl
modify column country set not null;

alter table cricket.clean.player_clean_tbl
modify column player_name set not null;
-- ####################################################


alter table cricket.clean.player_clean_tbl
add constraint pk_match_type_number primary key (match_type_number);

alter table cricket.clean.player_clean_tbl
add constraint fk_match_id
foreign key (match_type_number)
references cricket.clean.match_detail_clean (match_type_number);





