# SEL - GitHub CoPilot Software Development 

## This is the NoAI Case Study 2 Branch

[Here](https://github.com/WSUCptSCapstone-F23-S24/sel-githubcopilotassistedsoftwaredev/blob/main/readme.md) is a link to the main read me for this project.



## Approach 2 Setup 

Approach 2 requires a PostgreSQL installation. After retrieving the json data files, you must create the properly formatted tables using pgadmin4 or by running the provided create table statements. After that, run the 'filldatabase.py'. After completing this, Approach 2 will be able to be run.

Note: This assumes a complete default PostgreSQL installation, with a password as '123'

## Create Table using CREATE TABLE statements
### Zipcode Table
```sql
-- Table: public.zipcode

-- DROP TABLE IF EXISTS public.zipcode;

CREATE TABLE IF NOT EXISTS public.zipcode
(
    zipcode integer NOT NULL,
    population integer NOT NULL,
    avg_income integer NOT NULL,
    CONSTRAINT zipcode_pkey PRIMARY KEY (zipcode)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.zipcode
    OWNER to postgres;

COMMENT ON TABLE public.zipcode
    IS 'yelp_zipcode.json
';
```

### Business Table
```sql
-- Table: public.business

-- DROP TABLE IF EXISTS public.business;

CREATE TABLE IF NOT EXISTS public.business
(
    zipcode integer NOT NULL,
    review_count integer,
    stars double precision,
    checkins json,
    business_id character varying COLLATE pg_catalog."default" NOT NULL,
    city character varying COLLATE pg_catalog."default" NOT NULL,
    name character varying COLLATE pg_catalog."default" NOT NULL,
    state character varying COLLATE pg_catalog."default" NOT NULL,
    categories json,
    address character varying COLLATE pg_catalog."default",
    CONSTRAINT business_pkey PRIMARY KEY (business_id),
    CONSTRAINT zipcode FOREIGN KEY (zipcode)
        REFERENCES public.zipcode (zipcode) MATCH FULL
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.business
    OWNER to postgres;

COMMENT ON TABLE public.business
    IS 'yelp_business.json file';

COMMENT ON CONSTRAINT zipcode ON public.business
    IS 'zipcode in this table must match zipcode in zipcode table';
```

### Review Table
```sql
-- Table: public.review

-- DROP TABLE IF EXISTS public.review;

CREATE TABLE IF NOT EXISTS public.review
(
    stars integer NOT NULL,
    date date,
    business_id character varying COLLATE pg_catalog."default" NOT NULL,
    review_id character varying COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT review_pkey PRIMARY KEY (review_id),
    CONSTRAINT business FOREIGN KEY (business_id)
        REFERENCES public.business (business_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.review
    OWNER to postgres;

COMMENT ON TABLE public.review
    IS 'yelp_review.json';
```

## Create Table using pgadmin4 
### Tables
#### Business Table
![image](./Approach%202/Images/table1.png)
#### Review Table
![image](./Approach%202/Images/table2.png)
#### Zipcode Table
![image](./Approach%202/Images/table3.png)

### Relationships
#### Review Table
![image](./Approach%202/Images/relationship1.png)
#### Zipcode Table
![image](./Approach%202/Images/relationship2.png)