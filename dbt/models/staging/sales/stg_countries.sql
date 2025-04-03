with stg_countries as (
select
    CAST(id as Int) as id,
    CAST(lang_pt_br as String) as lang_pt_br,
    CAST(lang_pt_br_formatted as String) as lang_pt_br_formatted,
    CAST(lang_en as String) as lang_en,
    CAST(lang_en_formatted as String) as lang_en_formatted,
    CAST(alpha_2 as String) as alpha_2,
    CAST(alpha_3 as String) as alpha_3,
    CASE
        WHEN upper(alpha_2) IN ('DZ','AO','BJ','BW','BF','BI','CM','CV','CF','TD','KM','CD','CG','CI','DJ','EG','GQ','ER','ET','GA','GM','GH','GN','GW','KE','LS','LR','LY','MG','MW','ML','MR','MU','MA','MZ','NA','NE','NG', 'RE', 'RW','ST','SN','SC','SL','SO','ZA','SS','SD','SZ','TZ','TG','TN','UG','EH','ZM','ZW', 'YT', 'SH') THEN 'Africa'
        WHEN upper(alpha_2) IN ('AF','AM','AZ','BH','BD','BT','BN','KH','CN','CY','GE','IN','ID','IR','IQ','IL','JP','JO','KZ','KP','KR','KW','KG','LA','LB','MY','MV','MN','MM','NP','OM','PK','PS','PH','QA','SA','SG','LK','SY','TW','TJ','TH','TR','TM','AE','UZ','VN','YE', 'MO', 'TL', 'IO', 'HK') THEN 'Asia'
        WHEN upper(alpha_2) IN ('AI','AG','AR','AW','BS','BB','BZ','BM','BO','BR','VG','CA','KY','CL','CO','CR','CU','DM','DO','EC','SV','FK','GF','GL','GD','GP','GT','GY','HT','HN','JM','MQ','MX','MS','NI','PA','PY','PE','PR','BL','KN','LC','MF','PM','VC','SX','SR','TT','TC','US','UY','VE', 'CW', 'VI', 'BQ') THEN 'Americas'
        WHEN upper(alpha_2) IN ('AL','AD','AT','BY','BE','BA','BG','HR','CZ','DK','EE','FO','FI','FR','DE','GI','GR','GG','HU','IS','IE','IM','IT','JE','LV','LI','LT','LU','MT','MD','MC','ME','NL','MK','NO','PL','PT','RO','RU','SM','RS','SK','SI','ES','SJ','SE','CH','UA','GB','VA', 'AX') THEN 'Europe'
        WHEN upper(alpha_2) IN ('AS','AU','CX','CC','CK','FJ','PF','GU','HM','KI','MH','FM','NR','NC','NZ','NU','NF','MP','PW','PG','PN','WS','SB','TK','TO','TV','UM','VU','WF') THEN 'Oceania'
        WHEN upper(alpha_2) IN ('AQ','BV','TF','HM', 'GS') THEN 'Antarctica'
        ELSE 'Unknown'
        END AS continent,
    CAST(create_date_ts as DateTime) as create_date_ts
from  {{ source( 'sap', 'raw_countries') }}
)

select
*
from stg_countries
