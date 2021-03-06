--liquibase formatted sql

--This is for the sedmap schema
 
--changeset duselman:siteRefBasinView
--s.eco_l2_code as eco_l2_cod is because of shape file 10 char field name limit
create or replace view sedmap.SITE_REF_BASIN as
select s.*, b.basin_ids basin_no, s.eco_l2_code eco_l2_cod
from sedmap.site_ref s
left outer join sedmap.site_basin b on s.site_no=b.site_no;
grant select on SITE_REF_BASIN to seduser;
-- rollback drop view SITE_REF_BASIN;


--changeset duselman:CreateDiscreteStationsView
CREATE OR REPLACE FORCE VIEW "SEDMAP"."DISCRETE_STATIONS" AS 
select s.*, NVL2(b.SITE_NO, '1','0') as BENCHMARK_SITE
from sedmap.site_ref_basin s 
left outer join sedmap.BENCHMARK_SITES b 
            on s.SITE_NO = b.SITE_NO
where exists (select 1 
            from sedmap.discrete_sites i 
            where s.SITE_NO=i.SITE_NO);
grant select on DISCRETE_STATIONS to seduser;
-- rollback drop view DISCRETE_STATIONS;


--changeset duselman:CreateDailyStationsView
create or replace view sedmap.daily_stations as
select s.*, NVL2(b.SITE_NO, '1','0') as BENCHMARK_SITE
from sedmap.site_ref_basin s 
left join (select SITE_NO, count(*) sample_years 
            from sedmap.daily_year y 
            group by SITE_NO) y 
            on (y.SITE_NO = s.SITE_NO)
left outer join sedmap.BENCHMARK_SITES b 
            on s.SITE_NO = b.SITE_NO
where exists (select 1 
            from sedmap.daily_sites i 
            where s.SITE_NO=i.SITE_NO);
grant select on daily_stations to seduser;
-- rollback drop view daily_stations;

            
            
--changeset duselman:CreateSiteInfoView
create or replace view sedmap.SITE_INFO as
select s.*,
    y.minyr as daily_min, y.maxyr as daily_max, y.minyr ||'-'|| y.maxyr as Daily_Period,
    f.minyr as discrete_min, f.maxyr as discrete_max, f.minyr ||'-'|| f.maxyr as Discrete_Period,
      NVL( (select 1 from sedmap.daily_sites d where s.SITE_NO=d.SITE_NO) ,0) as daily_site,
      NVL( (select 1 from sedmap.discrete_sites  d where s.SITE_NO=d.SITE_NO) ,0) as discrete_site,
      NVL(y.sample_years,0) as daily_years,
      NVL(f.sample_count,0) as discrete_samples,
      NVL2(b.SITE_NO, '1','0') as BENCHMARK_SITE
  from sedmap.site_ref_basin s 
  left outer join sedmap.BENCHMARK_SITES b on s.SITE_NO = b.SITE_NO
  left outer join (
    select SITE_NO, count(*) sample_years, min(sample_year) minyr, max(sample_year) maxyr 
      from sedmap.daily_year y 
     group by SITE_NO) y 
  on (y.SITE_NO = s.SITE_NO)
  left outer join (
    select SITE_NO, count(*) sample_count, EXTRACT(year FROM min(datetime)) minyr, EXTRACT(year FROM max(datetime)) maxyr 
      from sedmap.discrete_sample_fact f 
     group by SITE_NO) f 
  on (f.SITE_NO = s.SITE_NO);
grant select on SITE_INFO to seduser;
-- rollback drop view SITE_INFO;


--changeset duselman:ecoRegion1View
create or replace view sedmap.ECO1NAMES as
select distinct ECO_L1_NAME ECO_NAME from sedmap.site_ref 
where ECO_L1_NAME is not null order by 1;
grant select on ECO1NAMES to seduser;
-- rollback drop view ECO1NAMES;

--changeset duselman:ecoRegion2View
create or replace view sedmap.ECO2NAMES as
select distinct ECO_L2_NAME ECO_NAME from sedmap.site_ref 
where ECO_L2_NAME is not null order by 1;
grant select on ECO2NAMES to seduser;
-- rollback drop view ECO2NAMES;

--changeset duselman:ecoRegion3View
create or replace view sedmap.ECO3NAMES as
select distinct ECO_L3_NAME ECO_NAME from sedmap.site_ref 
where ECO_L3_NAME is not null order by 1;
grant select on ECO3NAMES to seduser;
-- rollback drop view ECO3NAMES;



--changeset duselman:discreteStationDlView
CREATE OR REPLACE FORCE VIEW SEDMAP.DISCRETE_STATIONS_DL AS 
select s.SITE_NO,
  SNAME,
  LATITUDE,
  LONGITUDE,
  NWISDA1,
  STATE,
  COUNTY_NAME,
  ECO_L3_CODE,
  ECO_L3_NAME,
  ECO_L2_CODE,
  ECO_L2_NAME,
  ECO_L1_NAME,
  ECO_L1_CODE,
  HUC_REGION_NAME,
  HUC_SUBREGION_NAME,
  HUC_BASIN_NAME,
  HUC_SUBBASIN_NAME ,
  HUC_2,
  HUC_4,
  HUC_6,
  HUC_8,
  PERM,
  BFI,
  KFACT,
  RFACT ,
  PPT30 ,
  URBAN ,
  FOREST,
  AGRIC ,
  MAJ_DAMS,
  NID_STOR ,
  CLAY  ,
  SAND ,
  SILT,
  BENCHMARK_SITE,
  nhdp1,
  nhdp5,
  nhdp10,
  nhdp20,
  nhdp25,
  nhdp30,
  nhdp40,
  nhdp50,
  nhdp60,
  nhdp70,
  nhdp75,
  nhdp80,
  nhdp90,
  nhdp95,
  nhdp99,
  ECO_L2_COD, --  need to filter out on java side, needed for filtering
  BASIN_NO    --  need to filter out on java side, needed for filtering
from DISCRETE_STATIONS s
left join sedmap.flow_exceedance f on s.site_no=f.site_no;

grant select on DISCRETE_STATIONS_DL to seduser;
-- rollback drop view DISCRETE_STATIONS_DL;



--changeset duselman:dailyStationDlView
CREATE OR REPLACE FORCE VIEW SEDMAP.DAILY_STATIONS_DL AS 
select s.SITE_NO,
  SNAME,
  LATITUDE,
  LONGITUDE,
  NWISDA1,
  STATE,
  COUNTY_NAME,
  ECO_L3_CODE,
  ECO_L3_NAME,
  ECO_L2_CODE,
  ECO_L2_NAME,
  ECO_L1_NAME,
  ECO_L1_CODE,
  HUC_REGION_NAME,
  HUC_SUBREGION_NAME,
  HUC_BASIN_NAME,
  HUC_SUBBASIN_NAME ,
  HUC_2,
  HUC_4,
  HUC_6,
  HUC_8,
  PERM,
  BFI,
  KFACT,
  RFACT ,
  PPT30 ,
  URBAN ,
  FOREST,
  AGRIC ,
  MAJ_DAMS,
  NID_STOR ,
  CLAY  ,
  SAND ,
  SILT,
  BENCHMARK_SITE,
  nhdp1,
  nhdp5,
  nhdp10,
  nhdp20,
  nhdp25,
  nhdp30,
  nhdp40,
  nhdp50,
  nhdp60,
  nhdp70,
  nhdp75,
  nhdp80,
  nhdp90,
  nhdp95,
  nhdp99,
  ECO_L2_COD, --  need to filter out on java side, needed for filtering
  BASIN_NO    --  need to filter out on java side, needed for filtering
from DAILY_STATIONS s
left join sedmap.flow_exceedance f on s.site_no=f.site_no;

grant select on DAILY_STATIONS_DL to seduser;
-- rollback drop view DAILY_STATIONS_DL;
