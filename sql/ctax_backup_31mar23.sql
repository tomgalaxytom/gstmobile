--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.1
-- Dumped by pg_dump version 14.5

-- Started on 2023-03-31 15:40:29

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 8 (class 2615 OID 620498)
-- Name: mybillmyright; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA mybillmyright;


ALTER SCHEMA mybillmyright OWNER TO postgres;

--
-- TOC entry 241 (class 1255 OID 623489)
-- Name: fn_assigningcharge_jsondata(character varying, character varying, character varying, character varying, integer, integer); Type: FUNCTION; Schema: mybillmyright; Owner: postgres
--

CREATE FUNCTION mybillmyright.fn_assigningcharge_jsondata(_roletypecode character varying, _divisioncode character varying, _zonecode character varying, _distcode character varying, _circleid integer, _session_userid integer) RETURNS json
    LANGUAGE plpgsql
    AS $$
declare

		json_data json;

		_return_or_fwd_or_all character varying;

	BEGIN

	
	 SET search_path to mybillmyright;

	 json_data:=(select  array_to_json(array_agg(row_to_json(t)))from (
	

	SELECT DISTINCT 
		u.divisioncode,u.zonecode,u.distcode,u.circleid,uc.statusflag,ch.createdby,
		dist.distename,d.divisionlname,z.zonelname,c.circlename,u.name,
		u.userid,uc.statusflag AS status,u.profile_update,uc.createdon AS uc_createdon,u.roletypecode 

		FROM mst_charge ch

		JOIN mst_dept_user u ON u.roletypecode::text = ch.roletypecode::text
		LEFT JOIN mst_user_charge uc ON uc.userid = u.userid
		LEFT JOIN mst_division d ON d.divisioncode::text = u.divisioncode::text
		LEFT JOIN mst_district dist ON u.distcode::text = dist.distcode::text
		LEFT JOIN mst_zone z ON u.zonecode::text = z.zonecode::text
		LEFT JOIN mst_circle c ON u.circleid = c.circleid
		  WHERE (u.divisioncode=_divisioncode  or _divisioncode='A' ) and (u.distcode= _distcode or _distcode='A')
				and (u.zonecode= _zonecode or _zonecode='A') and (u.circleid=_circleid or _circleid=0)
				and u.userid <> _session_userid and uc.statusflag IS NULL and
				CASE
		 			WHEN ch.roletypecode = '02' THEN ch.circleid IS NULL AND u.userid IS NOT NULL AND uc.statusflag IS NULL
					WHEN ch.roletypecode = '04' THEN u.divisioncode::text = ch.divisioncode::text AND u.distcode::text = ch.distcode::text AND u.zonecode::text = ch.zonecode::text AND ch.circleid IS NULL AND u.userid IS NOT NULL AND uc.statusflag IS NULL
					WHEN ch.roletypecode = '03' THEN ch.zonecode IS NULL AND ch.circleid IS NULL AND u.divisioncode::text = ch.divisioncode::text AND u.userid IS NOT NULL AND uc.statusflag IS NULL
					WHEN ch.roletypecode = '05' THEN u.circleid::text = ch.circleid::text AND u.userid IS NOT NULL AND uc.statusflag IS NULL
		 
					ELSE NULL::boolean
				END
	  ORDER BY ch.createdby DESC ) t) ;

		   return json_data;

	 End;
$$;


ALTER FUNCTION mybillmyright.fn_assigningcharge_jsondata(_roletypecode character varying, _divisioncode character varying, _zonecode character varying, _distcode character varying, _circleid integer, _session_userid integer) OWNER TO postgres;

--
-- TOC entry 236 (class 1255 OID 623490)
-- Name: fn_chargedetails_jsondata(character varying, character varying, character varying, integer, character varying, integer); Type: FUNCTION; Schema: mybillmyright; Owner: postgres
--

CREATE FUNCTION mybillmyright.fn_chargedetails_jsondata(_roletypecode character varying, _divisioncode character varying, _zonecode character varying, _circleid integer, _distcode character varying, _session_chargeid integer) RETURNS json
    LANGUAGE plpgsql
    AS $$
declare

		json_data json;

	BEGIN

	 SET search_path to mybillmyright;

	 json_data:=(select  array_to_json(array_agg(row_to_json(t)))from (

		select dd.distename,c.circlename,u.chargedescription, 
		 
           u.createdon,d.divisioncode,r.roletypelname,d.divisionlname,z.zonelname,dd.distename,c.circlename,
		 
		    u.zonecode,u.chargeid

 from mst_charge u

left join mst_division d on d.divisioncode =u.divisioncode 

left join mst_zone z on u.zonecode = z.zonecode 
		 
left join mst_district dd on dd.distcode = u.distcode 

left join mst_circle c on c.circleid	=	u.circleid 

inner join mst_roletype r on r.roletypecode = u.roletypecode 

where  (u.divisioncode=_divisioncode  or _divisioncode='A' ) and (u.distcode= _distcode or _distcode='A')

     and (u.zonecode= _zonecode or _zonecode='A')   and (u.circleid=_circleid or _circleid=0) and u.chargeid <> _session_chargeid 
		 
		and u.roletypecode <> '06' and
		 		 
		 CASE
		 			WHEN _roletypecode = '01' THEN u.roletypecode <> '01'
					WHEN _roletypecode = '02' THEN u.roletypecode <> '01' AND u.roletypecode <> '02' 
					WHEN _roletypecode = '03' THEN u.roletypecode <> '01' AND u.roletypecode <>'02' AND u.roletypecode <> '03'
					WHEN _roletypecode = '04' THEN u.roletypecode <> '01' AND u.roletypecode <> '02' AND u.roletypecode <> '03' AND u.roletypecode <> '04'
		 End

	  order by u.createdon DESC 

	 ) t) ;

		   return json_data;

	 End;
$$;


ALTER FUNCTION mybillmyright.fn_chargedetails_jsondata(_roletypecode character varying, _divisioncode character varying, _zonecode character varying, _circleid integer, _distcode character varying, _session_chargeid integer) OWNER TO postgres;

--
-- TOC entry 242 (class 1255 OID 623491)
-- Name: fn_deptuserdetails_jsondata(character varying, character varying, character varying, integer, character varying, integer); Type: FUNCTION; Schema: mybillmyright; Owner: postgres
--

CREATE FUNCTION mybillmyright.fn_deptuserdetails_jsondata(_roletypecode character varying, _divisioncode character varying, _zonecode character varying, _circleid integer, _distcode character varying, _session_userid integer) RETURNS json
    LANGUAGE plpgsql
    AS $$
declare

		json_data json;

	BEGIN

	

	 SET search_path to mybillmyright;

	 json_data:=(select  array_to_json(array_agg(row_to_json(t)))from (

		select dd.distename,c.circlename,u.email,u.name,u.mobilenumber, 
		 
            u.userid,u.createdon,d.divisioncode,r.roletypelname,u.dateofbirth,d.divisionlname,z.zonelname,dd.distename,c.circlename,
		 
		    u.zonecode,u.circleid

 from mst_dept_user u

left join mst_division d on d.divisioncode =u.divisioncode 

left join mst_zone z on u.zonecode = z.zonecode 
		 
left join mst_district dd on dd.distcode = u.distcode 

left join mst_circle c on c.circleid	=	u.circleid 

inner join mst_roletype r on r.roletypecode = u.roletypecode 

where  (u.divisioncode=_divisioncode  or _divisioncode='A' ) and (u.distcode= _distcode or _distcode='A')

     and (u.zonecode= _zonecode or _zonecode='A')   and (u.circleid=_circleid or _circleid=0) and u.userid <> _session_userid 
		 
		 and u.roletypecode <> '06' and
		 		 
		 CASE
		 			WHEN _roletypecode = '01' THEN u.roletypecode <> '01'
					WHEN _roletypecode = '02' THEN u.roletypecode <> '01' AND u.roletypecode <> '02' 
					WHEN _roletypecode = '03' THEN u.roletypecode <> '01' AND u.roletypecode <>'02' AND u.roletypecode <> '03'
					WHEN _roletypecode = '04' THEN u.roletypecode <> '01' AND u.roletypecode <> '02' AND u.roletypecode <> '03' AND u.roletypecode <> '04'
		 End

	  order by u.createdon DESC 

	 ) t) ;

		   return json_data;

	 End;
$$;


ALTER FUNCTION mybillmyright.fn_deptuserdetails_jsondata(_roletypecode character varying, _divisioncode character varying, _zonecode character varying, _circleid integer, _distcode character varying, _session_userid integer) OWNER TO postgres;

--
-- TOC entry 237 (class 1255 OID 623492)
-- Name: fn_get_role_menu_det_jsondata(integer, character varying); Type: FUNCTION; Schema: mybillmyright; Owner: postgres
--

CREATE FUNCTION mybillmyright.fn_get_role_menu_det_jsondata(_roleid integer, _menu character varying) RETURNS json
    LANGUAGE plpgsql
    AS $$
declare

		json_data json;

		_fwdto_action_code integer;

	BEGIN

        SET search_path to mst_menu_mapping;

		if _menu='Y' then 

            json_data:=(select  array_to_json(array_agg(row_to_json(t)))from (

            SELECT menuname,key from mybillmyright.mst_menu_mapping

            LEFT JOIN jsonb_array_elements_text((control_json -> '1') ) as config

            ON TRUE

            LEFT JOIN mybillmyright.mst_menu ON  (config) = mybillmyright.mst_menu.menuid ::text  where (mst_menu_mapping.roleid=_roleid  or _roleid=0 )

             ) t) ;

	  elseif _menu='N' then 

        json_data:=(select  array_to_json(array_agg(row_to_json(t)))from (

	  	SELECT distinct(role_data.roleid),rolesname,rolelname,role_data.status from mybillmyright.mst_menu_mapping

        LEFT JOIN jsonb_array_elements_text((control_json -> '1') ) as config

        ON TRUE

        LEFT JOIN mybillmyright.mst_menu ON  (config) = mybillmyright.mst_menu.menuid ::text

        LEFT JOIN mybillmyright.mst_role role_data ON role_data.roleid = mybillmyright.mst_menu_mapping.roleid 

        where (role_data.roleid=_roleid  or _roleid=0 )  ) t) ;

	End if;

	 return json_data;

	 End;
$$;


ALTER FUNCTION mybillmyright.fn_get_role_menu_det_jsondata(_roleid integer, _menu character varying) OWNER TO postgres;

--
-- TOC entry 238 (class 1255 OID 623493)
-- Name: fn_get_rolepermission(integer); Type: FUNCTION; Schema: mybillmyright; Owner: postgres
--

CREATE FUNCTION mybillmyright.fn_get_rolepermission(_charge_id integer) RETURNS json
    LANGUAGE plpgsql
    AS $$

declare

		json_data json;

	BEGIN

        SET search_path to mybillmyright;

            json_data:=(select  array_to_json(array_agg(row_to_json(t)))from (

            SELECT control_json -> '1' AS control_json FROM mst_menu_mapping

                inner JOIN mst_charge charge ON  charge.roleid = mst_menu_mapping.roleid 

             where (chargeid=_charge_id  or _charge_id=0 )

             ) t) ;

	 return json_data;

	 End;

$$;


ALTER FUNCTION mybillmyright.fn_get_rolepermission(_charge_id integer) OWNER TO postgres;

--
-- TOC entry 239 (class 1255 OID 623494)
-- Name: fn_getcharge_basedon_roleid(integer, character varying, character varying, integer, character varying); Type: FUNCTION; Schema: mybillmyright; Owner: postgres
--

CREATE FUNCTION mybillmyright.fn_getcharge_basedon_roleid(_roleid integer, _divisioncode character varying, _zonecode character varying, _circleid integer, _distcode character varying) RETURNS json
    LANGUAGE plpgsql
    AS $$
declare

		json_data json;

		_return_or_fwd_or_all character varying;

	BEGIN

	
	 SET search_path to mybillmyright;

	 json_data:=(select  array_to_json(array_agg(row_to_json(t)))from (

select * from mst_charge a

where  (a.divisioncode=_divisioncode  or _divisioncode='A' ) 
		 
		 and (a.zonecode= _zonecode or _zonecode='A')
		 
		  and (a.circleid=_circleid or _circleid=0)

        and (a.distcode=_distcode or _distcode='A') and a.roleid=_roleid 

	  order by a.createdby DESC 

	 ) t) ;

		   return json_data;

	 End;
$$;


ALTER FUNCTION mybillmyright.fn_getcharge_basedon_roleid(_roleid integer, _divisioncode character varying, _zonecode character varying, _circleid integer, _distcode character varying) OWNER TO postgres;

--
-- TOC entry 240 (class 1255 OID 623495)
-- Name: fn_getcharge_basedon_roleid(character varying, character varying, character varying, integer, character varying); Type: FUNCTION; Schema: mybillmyright; Owner: postgres
--

CREATE FUNCTION mybillmyright.fn_getcharge_basedon_roleid(_roletypecode character varying, _divisioncode character varying, _zonecode character varying, _circleid integer, _distcode character varying) RETURNS json
    LANGUAGE plpgsql
    AS $$
declare

		json_data json;

		_return_or_fwd_or_all character varying;

	BEGIN

	
	 SET search_path to mybillmyright;

	 json_data:=(select  array_to_json(array_agg(row_to_json(t)))from (

select * from mst_charge a

where  (a.divisioncode=_divisioncode  or _divisioncode='A' ) 
		 
		 and (a.zonecode= _zonecode or _zonecode='A')
		 
		  and (a.circleid=_circleid or _circleid=0)

        and (a.distcode=_distcode or _distcode='A') and a.roletypecode=_roletypecode 

	  order by a.createdby DESC 

	 ) t) ;

		   return json_data;

	 End;
$$;


ALTER FUNCTION mybillmyright.fn_getcharge_basedon_roleid(_roletypecode character varying, _divisioncode character varying, _zonecode character varying, _circleid integer, _distcode character varying) OWNER TO postgres;

--
-- TOC entry 243 (class 1255 OID 622327)
-- Name: getawknumber(character varying); Type: FUNCTION; Schema: mybillmyright; Owner: nursec
--

CREATE FUNCTION mybillmyright.getawknumber(distcode character varying) RETURNS SETOF record
    LANGUAGE plpgsql COST 10
    AS $$

DECLARE

	yearmonth character varying;
	deviceid character varying;
	mobilenumber character varying;
	rec record;
	rec1 record;
	
	
	--select * from billdetail

BEGIN

			
        for rec in execute 'SELECT concat(20,mc.yymm )  as yearmonth,mu.deviceid as deviceid ,mc.distcode as distcode,
            substring(mu.mobilenumber , 8) as mobilelastthreedigit
        FROM mybillmyright.mst_config as mc
        INNER JOIN mybillmyright.mst_user as mu
        ON mc.distcode = mu.distcode where mc.distcode = '''||distcode||''''
		loop

		--trans_id=rec.trans_id+1;
		yearmonth = rec.yearmonth;
		deviceid       = rec.deviceid;
		mobilenumber = rec.mobilelastthreedigit; 
		
		
		raise notice 'recwrk-----%',yearmonth;
	
	
		end loop; 
	
		for rec1 in select yearmonth , distcode ,deviceid,mobilenumber  loop		 	 
			 
	 	end loop; 
	 
		return next rec1;
END
	
/*   				  
	select * FROM mybillmyright.getAwkNumber('610') AS RECORD(yearmonth character varying,distcode character varying ,deviceid character varying,mobilenumber character varying);
*/
$$;


ALTER FUNCTION mybillmyright.getawknumber(distcode character varying) OWNER TO nursec;

--
-- TOC entry 223 (class 1255 OID 622940)
-- Name: invoice_count_values(); Type: FUNCTION; Schema: mybillmyright; Owner: nursec
--

CREATE FUNCTION mybillmyright.invoice_count_values() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (select count(*) from mybillmyright.mst_config where CURRENT_DATE between billentrystartdate and billentryenddate
);
END;
$$;


ALTER FUNCTION mybillmyright.invoice_count_values() OWNER TO nursec;

SET default_tablespace = '';

--
-- TOC entry 184 (class 1259 OID 620499)
-- Name: billdetail; Type: TABLE; Schema: mybillmyright; Owner: postgres
--

CREATE TABLE mybillmyright.billdetail (
    billdetailid integer NOT NULL,
    userid integer NOT NULL,
    configcode character varying(2) NOT NULL,
    mobilenumber character varying(10) NOT NULL,
    billnumber character varying(10) NOT NULL,
    billdate date NOT NULL,
    shopname character varying(100) NOT NULL,
    billamount numeric NOT NULL,
    statecode character varying(2) NOT NULL,
    distcode character varying(3) NOT NULL,
    filename character varying(200),
    fileextension character varying(20),
    filesize character varying(10),
    mimetype character varying(50),
    filepath character varying(200),
    acknumber character varying(25) NOT NULL,
    uploadedby integer DEFAULT 1,
    uploadedon timestamp without time zone,
    statusflag character(1)
);


ALTER TABLE mybillmyright.billdetail OWNER TO postgres;

--
-- TOC entry 185 (class 1259 OID 620506)
-- Name: billdetail_billdetailid_seq; Type: SEQUENCE; Schema: mybillmyright; Owner: postgres
--

CREATE SEQUENCE mybillmyright.billdetail_billdetailid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE mybillmyright.billdetail_billdetailid_seq OWNER TO postgres;

--
-- TOC entry 3247 (class 0 OID 0)
-- Dependencies: 185
-- Name: billdetail_billdetailid_seq; Type: SEQUENCE OWNED BY; Schema: mybillmyright; Owner: postgres
--

ALTER SEQUENCE mybillmyright.billdetail_billdetailid_seq OWNED BY mybillmyright.billdetail.billdetailid;


--
-- TOC entry 198 (class 1259 OID 623345)
-- Name: mst_charge; Type: TABLE; Schema: mybillmyright; Owner: postgres
--

CREATE TABLE mybillmyright.mst_charge (
    chargeid integer NOT NULL,
    chargecode character varying(20),
    chargedescription character varying(100),
    divisioncode character varying(3),
    zonecode character varying(3),
    configcode character varying(2),
    statusflag character varying(1),
    createdby integer,
    updatedby integer,
    createdon timestamp without time zone,
    updatedon timestamp without time zone,
    roleid integer,
    distcode character varying(3),
    circleid integer,
    roletypecode character varying(2),
    roleactioncode character varying(2)
);


ALTER TABLE mybillmyright.mst_charge OWNER TO postgres;

--
-- TOC entry 197 (class 1259 OID 623343)
-- Name: mst_charge_chargeid_seq; Type: SEQUENCE; Schema: mybillmyright; Owner: postgres
--

CREATE SEQUENCE mybillmyright.mst_charge_chargeid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE mybillmyright.mst_charge_chargeid_seq OWNER TO postgres;

--
-- TOC entry 3250 (class 0 OID 0)
-- Dependencies: 197
-- Name: mst_charge_chargeid_seq; Type: SEQUENCE OWNED BY; Schema: mybillmyright; Owner: postgres
--

ALTER SEQUENCE mybillmyright.mst_charge_chargeid_seq OWNED BY mybillmyright.mst_charge.chargeid;


--
-- TOC entry 200 (class 1259 OID 623353)
-- Name: mst_circle; Type: TABLE; Schema: mybillmyright; Owner: postgres
--

CREATE TABLE mybillmyright.mst_circle (
    circleid integer NOT NULL,
    circlecode character varying(4) NOT NULL,
    circlename character varying(100),
    divisioncode character varying(4) NOT NULL,
    zonecode character varying(4) NOT NULL,
    distcode character varying(4) NOT NULL,
    state_code character varying,
    status_flag character(1),
    createdby integer,
    createdon timestamp without time zone,
    updatedby integer,
    updatedon timestamp without time zone
);


ALTER TABLE mybillmyright.mst_circle OWNER TO postgres;

--
-- TOC entry 199 (class 1259 OID 623351)
-- Name: mst_circle_circleid_seq; Type: SEQUENCE; Schema: mybillmyright; Owner: postgres
--

CREATE SEQUENCE mybillmyright.mst_circle_circleid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE mybillmyright.mst_circle_circleid_seq OWNER TO postgres;

--
-- TOC entry 3253 (class 0 OID 0)
-- Dependencies: 199
-- Name: mst_circle_circleid_seq; Type: SEQUENCE OWNED BY; Schema: mybillmyright; Owner: postgres
--

ALTER SEQUENCE mybillmyright.mst_circle_circleid_seq OWNED BY mybillmyright.mst_circle.circleid;


--
-- TOC entry 186 (class 1259 OID 620508)
-- Name: mst_config; Type: TABLE; Schema: mybillmyright; Owner: postgres
--

CREATE TABLE mybillmyright.mst_config (
    configid integer NOT NULL,
    schemecode character varying(2) NOT NULL,
    configcode character varying(2) NOT NULL,
    statecode character varying(2) NOT NULL,
    distcode character varying(3) NOT NULL,
    minimumbillamt integer,
    prizeamount bigint,
    billentrystartdate timestamp without time zone,
    billentryenddate timestamp without time zone,
    billpurchasestartdate timestamp without time zone,
    billpurchaseenddate timestamp without time zone,
    billdrawdate timestamp without time zone,
    yymm character varying(6) NOT NULL,
    statusflag character(1),
    createdby integer,
    createdon timestamp without time zone,
    updatedby integer,
    updatedon timestamp without time zone
);


ALTER TABLE mybillmyright.mst_config OWNER TO postgres;

--
-- TOC entry 187 (class 1259 OID 620511)
-- Name: mst_configlog; Type: TABLE; Schema: mybillmyright; Owner: postgres
--

CREATE TABLE mybillmyright.mst_configlog (
    configlogid integer NOT NULL,
    configid integer NOT NULL,
    schemecode character varying(2) NOT NULL,
    configcode character varying(2) NOT NULL,
    statecode character varying(2) NOT NULL,
    distcode character varying(3) NOT NULL,
    minimumbillamt integer,
    prizeamount bigint,
    billentrystartdate timestamp without time zone,
    billentryenddate timestamp without time zone,
    billpurchasestartdate timestamp without time zone,
    billpurchaseenddate timestamp without time zone,
    billdrawdate timestamp without time zone,
    yymm character varying(6) NOT NULL,
    statusflag character(1),
    createdby integer,
    createdon timestamp without time zone,
    updatedby integer,
    updatedon timestamp without time zone
);


ALTER TABLE mybillmyright.mst_configlog OWNER TO postgres;

--
-- TOC entry 202 (class 1259 OID 623364)
-- Name: mst_dept_user; Type: TABLE; Schema: mybillmyright; Owner: postgres
--

CREATE TABLE mybillmyright.mst_dept_user (
    userid integer NOT NULL,
    email character varying(50) NOT NULL,
    pwd character varying(200),
    name character varying(50) NOT NULL,
    mobilenumber character varying(10) NOT NULL,
    statecode character varying(2) DEFAULT 'TN'::character varying NOT NULL,
    distcode character varying(3),
    createdby integer DEFAULT 1 NOT NULL,
    createdon timestamp without time zone,
    updatedby integer DEFAULT 1,
    updatedon timestamp without time zone,
    statusflag boolean DEFAULT true,
    profile_update character(1),
    divisioncode character varying(4),
    zonecode character varying(4),
    circleid integer,
    dateofbirth date,
    nodal character(1),
    lott_executor character(1),
    empid character varying(10),
    roletypecode character varying(2)
);


ALTER TABLE mybillmyright.mst_dept_user OWNER TO postgres;

--
-- TOC entry 201 (class 1259 OID 623362)
-- Name: mst_dept_user_userid_seq; Type: SEQUENCE; Schema: mybillmyright; Owner: postgres
--

CREATE SEQUENCE mybillmyright.mst_dept_user_userid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE mybillmyright.mst_dept_user_userid_seq OWNER TO postgres;

--
-- TOC entry 3258 (class 0 OID 0)
-- Dependencies: 201
-- Name: mst_dept_user_userid_seq; Type: SEQUENCE OWNED BY; Schema: mybillmyright; Owner: postgres
--

ALTER SEQUENCE mybillmyright.mst_dept_user_userid_seq OWNED BY mybillmyright.mst_dept_user.userid;


--
-- TOC entry 188 (class 1259 OID 620514)
-- Name: mst_district; Type: TABLE; Schema: mybillmyright; Owner: postgres
--

CREATE TABLE mybillmyright.mst_district (
    distid integer NOT NULL,
    distcode character varying(3) NOT NULL,
    statecode character varying(2),
    distename character varying(50),
    flag character(1),
    createdon timestamp without time zone,
    createdby integer,
    updatedby integer,
    updatedon timestamp without time zone
);


ALTER TABLE mybillmyright.mst_district OWNER TO postgres;

--
-- TOC entry 204 (class 1259 OID 623381)
-- Name: mst_division; Type: TABLE; Schema: mybillmyright; Owner: postgres
--

CREATE TABLE mybillmyright.mst_division (
    divisionid integer NOT NULL,
    divisioncode character varying(2) NOT NULL,
    divisionsname character varying(10),
    divisionlname character varying(100),
    statecode character varying,
    statusflag character(1),
    createdby integer,
    createdon timestamp without time zone,
    updatedby integer,
    updatedon timestamp without time zone
);


ALTER TABLE mybillmyright.mst_division OWNER TO postgres;

--
-- TOC entry 203 (class 1259 OID 623379)
-- Name: mst_division_divisionid_seq; Type: SEQUENCE; Schema: mybillmyright; Owner: postgres
--

CREATE SEQUENCE mybillmyright.mst_division_divisionid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE mybillmyright.mst_division_divisionid_seq OWNER TO postgres;

--
-- TOC entry 3262 (class 0 OID 0)
-- Dependencies: 203
-- Name: mst_division_divisionid_seq; Type: SEQUENCE OWNED BY; Schema: mybillmyright; Owner: postgres
--

ALTER SEQUENCE mybillmyright.mst_division_divisionid_seq OWNED BY mybillmyright.mst_division.divisionid;


--
-- TOC entry 206 (class 1259 OID 623392)
-- Name: mst_menu; Type: TABLE; Schema: mybillmyright; Owner: postgres
--

CREATE TABLE mybillmyright.mst_menu (
    menuid integer NOT NULL,
    statecode character varying(3),
    menuname character varying(50),
    levelid integer,
    parentid integer,
    menuurl character varying(200),
    status character varying(1),
    createdby integer,
    createdon timestamp without time zone,
    updatedby integer,
    updatedon timestamp without time zone,
    key character varying(30),
    order_id integer
);


ALTER TABLE mybillmyright.mst_menu OWNER TO postgres;

--
-- TOC entry 208 (class 1259 OID 623400)
-- Name: mst_menu_mapping; Type: TABLE; Schema: mybillmyright; Owner: postgres
--

CREATE TABLE mybillmyright.mst_menu_mapping (
    menuid integer NOT NULL,
    roleid integer NOT NULL,
    control_json jsonb
);


ALTER TABLE mybillmyright.mst_menu_mapping OWNER TO postgres;

--
-- TOC entry 207 (class 1259 OID 623398)
-- Name: mst_menu_mapping_menuid_seq; Type: SEQUENCE; Schema: mybillmyright; Owner: postgres
--

CREATE SEQUENCE mybillmyright.mst_menu_mapping_menuid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE mybillmyright.mst_menu_mapping_menuid_seq OWNER TO postgres;

--
-- TOC entry 3266 (class 0 OID 0)
-- Dependencies: 207
-- Name: mst_menu_mapping_menuid_seq; Type: SEQUENCE OWNED BY; Schema: mybillmyright; Owner: postgres
--

ALTER SEQUENCE mybillmyright.mst_menu_mapping_menuid_seq OWNED BY mybillmyright.mst_menu_mapping.menuid;


--
-- TOC entry 205 (class 1259 OID 623390)
-- Name: mst_menu_menuid_seq; Type: SEQUENCE; Schema: mybillmyright; Owner: postgres
--

CREATE SEQUENCE mybillmyright.mst_menu_menuid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE mybillmyright.mst_menu_menuid_seq OWNER TO postgres;

--
-- TOC entry 3268 (class 0 OID 0)
-- Dependencies: 205
-- Name: mst_menu_menuid_seq; Type: SEQUENCE OWNED BY; Schema: mybillmyright; Owner: postgres
--

ALTER SEQUENCE mybillmyright.mst_menu_menuid_seq OWNED BY mybillmyright.mst_menu.menuid;


--
-- TOC entry 210 (class 1259 OID 623411)
-- Name: mst_role; Type: TABLE; Schema: mybillmyright; Owner: postgres
--

CREATE TABLE mybillmyright.mst_role (
    roleid integer NOT NULL,
    statecode character varying(3),
    rolesname character varying(50),
    rolelname character varying(100),
    status character(1),
    createdby integer,
    createdon timestamp without time zone,
    updatedby integer,
    updatedon timestamp without time zone,
    usertypecode character varying(2),
    roletypecode character varying(2),
    roleactioncode character varying(2)
);


ALTER TABLE mybillmyright.mst_role OWNER TO postgres;

--
-- TOC entry 209 (class 1259 OID 623409)
-- Name: mst_role_roleid_seq; Type: SEQUENCE; Schema: mybillmyright; Owner: postgres
--

CREATE SEQUENCE mybillmyright.mst_role_roleid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE mybillmyright.mst_role_roleid_seq OWNER TO postgres;

--
-- TOC entry 3271 (class 0 OID 0)
-- Dependencies: 209
-- Name: mst_role_roleid_seq; Type: SEQUENCE OWNED BY; Schema: mybillmyright; Owner: postgres
--

ALTER SEQUENCE mybillmyright.mst_role_roleid_seq OWNED BY mybillmyright.mst_role.roleid;


--
-- TOC entry 212 (class 1259 OID 623419)
-- Name: mst_roleaction; Type: TABLE; Schema: mybillmyright; Owner: postgres
--

CREATE TABLE mybillmyright.mst_roleaction (
    roleactionid integer NOT NULL,
    roleactioncode character varying(2),
    roleactionsname character varying(3),
    roleactionlname character varying(50),
    statusflag character(1),
    createdby integer,
    createdon time without time zone,
    updatedby integer,
    updatedon time without time zone,
    roletypecode character varying(2)
);


ALTER TABLE mybillmyright.mst_roleaction OWNER TO postgres;

--
-- TOC entry 211 (class 1259 OID 623417)
-- Name: mst_roleaction_roleactionid_seq; Type: SEQUENCE; Schema: mybillmyright; Owner: postgres
--

CREATE SEQUENCE mybillmyright.mst_roleaction_roleactionid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE mybillmyright.mst_roleaction_roleactionid_seq OWNER TO postgres;

--
-- TOC entry 3274 (class 0 OID 0)
-- Dependencies: 211
-- Name: mst_roleaction_roleactionid_seq; Type: SEQUENCE OWNED BY; Schema: mybillmyright; Owner: postgres
--

ALTER SEQUENCE mybillmyright.mst_roleaction_roleactionid_seq OWNED BY mybillmyright.mst_roleaction.roleactionid;


--
-- TOC entry 214 (class 1259 OID 623427)
-- Name: mst_roletype; Type: TABLE; Schema: mybillmyright; Owner: postgres
--

CREATE TABLE mybillmyright.mst_roletype (
    roletypeid integer NOT NULL,
    roletypecode character varying(2),
    roletypelname character varying(50),
    statusflag character(1),
    createdby integer,
    createdon timestamp without time zone,
    updatedby integer,
    updatedon timestamp without time zone,
    usertypecode character varying(2)
);


ALTER TABLE mybillmyright.mst_roletype OWNER TO postgres;

--
-- TOC entry 213 (class 1259 OID 623425)
-- Name: mst_roletype_roletypeid_seq; Type: SEQUENCE; Schema: mybillmyright; Owner: postgres
--

CREATE SEQUENCE mybillmyright.mst_roletype_roletypeid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE mybillmyright.mst_roletype_roletypeid_seq OWNER TO postgres;

--
-- TOC entry 3277 (class 0 OID 0)
-- Dependencies: 213
-- Name: mst_roletype_roletypeid_seq; Type: SEQUENCE OWNED BY; Schema: mybillmyright; Owner: postgres
--

ALTER SEQUENCE mybillmyright.mst_roletype_roletypeid_seq OWNED BY mybillmyright.mst_roletype.roletypeid;


--
-- TOC entry 189 (class 1259 OID 620517)
-- Name: mst_scheme; Type: TABLE; Schema: mybillmyright; Owner: postgres
--

CREATE TABLE mybillmyright.mst_scheme (
    schemeid integer NOT NULL,
    schemecode character varying(2) NOT NULL,
    schemesname character varying(10),
    schemelname character varying(50),
    minimumbillamt integer,
    prizeamount bigint,
    billentrystartdate timestamp without time zone,
    billentryenddate timestamp without time zone,
    billpurchasestartdate timestamp without time zone,
    billpurchaseenddate timestamp without time zone,
    billdrawdate timestamp without time zone,
    finyear integer,
    statusflag character(1),
    yymm character varying(6) NOT NULL,
    configstate_dist character(1) NOT NULL,
    createdby integer,
    createdon timestamp without time zone,
    updatedby integer,
    updatedon timestamp without time zone
);


ALTER TABLE mybillmyright.mst_scheme OWNER TO postgres;

--
-- TOC entry 190 (class 1259 OID 620520)
-- Name: mst_state; Type: TABLE; Schema: mybillmyright; Owner: postgres
--

CREATE TABLE mybillmyright.mst_state (
    stateid integer NOT NULL,
    statecode character varying(2) NOT NULL,
    stateename character varying(50),
    statetname character varying(50),
    stateut character varying(1),
    flag character varying(1),
    createdon timestamp without time zone,
    createdby integer,
    updatedby integer,
    updatedon timestamp without time zone
);


ALTER TABLE mybillmyright.mst_state OWNER TO postgres;

--
-- TOC entry 191 (class 1259 OID 620523)
-- Name: mst_user; Type: TABLE; Schema: mybillmyright; Owner: postgres
--

CREATE TABLE mybillmyright.mst_user (
    userid integer NOT NULL,
    schemecode character varying(2) DEFAULT '01'::character varying NOT NULL,
    email character varying(50) NOT NULL,
    pwd character varying(200),
    name character varying(50) NOT NULL,
    mobilenumber character varying(10) NOT NULL,
    statecode character varying(2) DEFAULT 'TN'::character varying NOT NULL,
    distcode character varying(3),
    ipaddress character varying(20),
    deviceid character varying(1),
    addr1 character varying(100) DEFAULT 'Address 1'::character varying NOT NULL,
    addr2 character varying(100) DEFAULT 'Address 2'::character varying NOT NULL,
    pincode character varying(6) DEFAULT '600000'::character varying NOT NULL,
    createdby integer DEFAULT 1 NOT NULL,
    createdon timestamp without time zone,
    updatedby integer DEFAULT 1,
    updatedon timestamp without time zone,
    statusflag boolean DEFAULT true,
    profile_update character(1),
    chargeid integer,
    roleid integer,
    roletypecode character varying(2)
);


ALTER TABLE mybillmyright.mst_user OWNER TO postgres;

--
-- TOC entry 216 (class 1259 OID 623435)
-- Name: mst_user_charge; Type: TABLE; Schema: mybillmyright; Owner: postgres
--

CREATE TABLE mybillmyright.mst_user_charge (
    userchargeid integer NOT NULL,
    statecode character varying(3),
    userid integer,
    divisioncode character varying(3),
    zonecode character varying(3),
    configcode character varying(2),
    charge_from date,
    statusflag character varying(1),
    createdby integer,
    createdon timestamp without time zone,
    updatedby integer,
    updatedon timestamp without time zone,
    chargeid integer,
    roleid integer,
    circleid integer,
    distcode character varying(3),
    roletypecode character varying(2)
);


ALTER TABLE mybillmyright.mst_user_charge OWNER TO postgres;

--
-- TOC entry 215 (class 1259 OID 623433)
-- Name: mst_user_charge_userchargeid_seq; Type: SEQUENCE; Schema: mybillmyright; Owner: postgres
--

CREATE SEQUENCE mybillmyright.mst_user_charge_userchargeid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE mybillmyright.mst_user_charge_userchargeid_seq OWNER TO postgres;

--
-- TOC entry 3283 (class 0 OID 0)
-- Dependencies: 215
-- Name: mst_user_charge_userchargeid_seq; Type: SEQUENCE OWNED BY; Schema: mybillmyright; Owner: postgres
--

ALTER SEQUENCE mybillmyright.mst_user_charge_userchargeid_seq OWNED BY mybillmyright.mst_user_charge.userchargeid;


--
-- TOC entry 192 (class 1259 OID 620537)
-- Name: mst_user_userid_seq; Type: SEQUENCE; Schema: mybillmyright; Owner: postgres
--

CREATE SEQUENCE mybillmyright.mst_user_userid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE mybillmyright.mst_user_userid_seq OWNER TO postgres;

--
-- TOC entry 3285 (class 0 OID 0)
-- Dependencies: 192
-- Name: mst_user_userid_seq; Type: SEQUENCE OWNED BY; Schema: mybillmyright; Owner: postgres
--

ALTER SEQUENCE mybillmyright.mst_user_userid_seq OWNED BY mybillmyright.mst_user.userid;


--
-- TOC entry 222 (class 1259 OID 623463)
-- Name: mst_userlog; Type: TABLE; Schema: mybillmyright; Owner: postgres
--

CREATE TABLE mybillmyright.mst_userlog (
    userlogid integer NOT NULL,
    userid integer NOT NULL,
    schemecode character varying(2) NOT NULL,
    email character varying(50) NOT NULL,
    pwd character varying(300),
    name character varying(50) NOT NULL,
    mobilenumber character varying(10) NOT NULL,
    statusflag character(1) DEFAULT true NOT NULL,
    statecode character varying(2),
    distcode character varying(3),
    ipaddress character varying(20),
    deviceid character varying(1),
    addr1 character varying(100),
    adr2 character varying(100),
    pincode integer,
    createdby integer DEFAULT 1 NOT NULL,
    createdon timestamp without time zone,
    updatedby integer DEFAULT 1,
    updatedon timestamp without time zone
);


ALTER TABLE mybillmyright.mst_userlog OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 623461)
-- Name: mst_userlog_userlogid_seq; Type: SEQUENCE; Schema: mybillmyright; Owner: postgres
--

CREATE SEQUENCE mybillmyright.mst_userlog_userlogid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE mybillmyright.mst_userlog_userlogid_seq OWNER TO postgres;

--
-- TOC entry 3288 (class 0 OID 0)
-- Dependencies: 221
-- Name: mst_userlog_userlogid_seq; Type: SEQUENCE OWNED BY; Schema: mybillmyright; Owner: postgres
--

ALTER SEQUENCE mybillmyright.mst_userlog_userlogid_seq OWNED BY mybillmyright.mst_userlog.userlogid;


--
-- TOC entry 193 (class 1259 OID 620550)
-- Name: mst_userlogindetail; Type: TABLE; Schema: mybillmyright; Owner: postgres
--

CREATE TABLE mybillmyright.mst_userlogindetail (
    userid integer NOT NULL,
    mobilenumber character varying(10) NOT NULL,
    ipaddress character varying(20),
    deviceid character varying(1),
    logintime timestamp without time zone,
    logouttime timestamp without time zone,
    logoutstatus integer NOT NULL,
    userloginid integer NOT NULL
);


ALTER TABLE mybillmyright.mst_userlogindetail OWNER TO postgres;

--
-- TOC entry 194 (class 1259 OID 620553)
-- Name: mst_userlogindetail_userloginid_seq; Type: SEQUENCE; Schema: mybillmyright; Owner: postgres
--

CREATE SEQUENCE mybillmyright.mst_userlogindetail_userloginid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE mybillmyright.mst_userlogindetail_userloginid_seq OWNER TO postgres;

--
-- TOC entry 3291 (class 0 OID 0)
-- Dependencies: 194
-- Name: mst_userlogindetail_userloginid_seq; Type: SEQUENCE OWNED BY; Schema: mybillmyright; Owner: postgres
--

ALTER SEQUENCE mybillmyright.mst_userlogindetail_userloginid_seq OWNED BY mybillmyright.mst_userlogindetail.userloginid;


--
-- TOC entry 218 (class 1259 OID 623443)
-- Name: mst_usertype; Type: TABLE; Schema: mybillmyright; Owner: postgres
--

CREATE TABLE mybillmyright.mst_usertype (
    usertypeid integer NOT NULL,
    usertypesname character varying(50),
    usertypelname character varying(100),
    status character(1),
    createdby integer,
    createdon timestamp without time zone,
    updatedby integer,
    updatedon timestamp without time zone,
    usertypecode character varying(2) NOT NULL
);


ALTER TABLE mybillmyright.mst_usertype OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 623441)
-- Name: mst_usertype_usertypeid_seq; Type: SEQUENCE; Schema: mybillmyright; Owner: postgres
--

CREATE SEQUENCE mybillmyright.mst_usertype_usertypeid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE mybillmyright.mst_usertype_usertypeid_seq OWNER TO postgres;

--
-- TOC entry 3294 (class 0 OID 0)
-- Dependencies: 217
-- Name: mst_usertype_usertypeid_seq; Type: SEQUENCE OWNED BY; Schema: mybillmyright; Owner: postgres
--

ALTER SEQUENCE mybillmyright.mst_usertype_usertypeid_seq OWNED BY mybillmyright.mst_usertype.usertypeid;


--
-- TOC entry 220 (class 1259 OID 623451)
-- Name: mst_zone; Type: TABLE; Schema: mybillmyright; Owner: postgres
--

CREATE TABLE mybillmyright.mst_zone (
    zoneid integer NOT NULL,
    zonecode character varying(2) NOT NULL,
    zonesname character varying(10),
    zonelname character varying(100),
    statecode character varying,
    statusflag character(1),
    createdby integer,
    createdon timestamp without time zone,
    updatedby integer,
    updatedon timestamp without time zone
);


ALTER TABLE mybillmyright.mst_zone OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 623449)
-- Name: mst_zone_zoneid_seq; Type: SEQUENCE; Schema: mybillmyright; Owner: postgres
--

CREATE SEQUENCE mybillmyright.mst_zone_zoneid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE mybillmyright.mst_zone_zoneid_seq OWNER TO postgres;

--
-- TOC entry 3297 (class 0 OID 0)
-- Dependencies: 219
-- Name: mst_zone_zoneid_seq; Type: SEQUENCE OWNED BY; Schema: mybillmyright; Owner: postgres
--

ALTER SEQUENCE mybillmyright.mst_zone_zoneid_seq OWNED BY mybillmyright.mst_zone.zoneid;


--
-- TOC entry 195 (class 1259 OID 620555)
-- Name: test; Type: TABLE; Schema: mybillmyright; Owner: postgres
--

CREATE TABLE mybillmyright.test (
    id integer NOT NULL,
    fname character varying NOT NULL
);


ALTER TABLE mybillmyright.test OWNER TO postgres;

--
-- TOC entry 196 (class 1259 OID 620561)
-- Name: test_id_seq; Type: SEQUENCE; Schema: mybillmyright; Owner: postgres
--

CREATE SEQUENCE mybillmyright.test_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE mybillmyright.test_id_seq OWNER TO postgres;

--
-- TOC entry 3300 (class 0 OID 0)
-- Dependencies: 196
-- Name: test_id_seq; Type: SEQUENCE OWNED BY; Schema: mybillmyright; Owner: postgres
--

ALTER SEQUENCE mybillmyright.test_id_seq OWNED BY mybillmyright.test.id;


--
-- TOC entry 183 (class 1259 OID 585136)
-- Name: test; Type: TABLE; Schema: public; Owner: nursec
--

CREATE TABLE public.test (
    id integer NOT NULL,
    name character varying(20)
);


ALTER TABLE public.test OWNER TO nursec;

--
-- TOC entry 182 (class 1259 OID 585134)
-- Name: test_id_seq; Type: SEQUENCE; Schema: public; Owner: nursec
--

CREATE SEQUENCE public.test_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.test_id_seq OWNER TO nursec;

--
-- TOC entry 3302 (class 0 OID 0)
-- Dependencies: 182
-- Name: test_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nursec
--

ALTER SEQUENCE public.test_id_seq OWNED BY public.test.id;


--
-- TOC entry 2991 (class 2604 OID 620563)
-- Name: billdetail billdetailid; Type: DEFAULT; Schema: mybillmyright; Owner: postgres
--

ALTER TABLE ONLY mybillmyright.billdetail ALTER COLUMN billdetailid SET DEFAULT nextval('mybillmyright.billdetail_billdetailid_seq'::regclass);


--
-- TOC entry 3003 (class 2604 OID 623348)
-- Name: mst_charge chargeid; Type: DEFAULT; Schema: mybillmyright; Owner: postgres
--

ALTER TABLE ONLY mybillmyright.mst_charge ALTER COLUMN chargeid SET DEFAULT nextval('mybillmyright.mst_charge_chargeid_seq'::regclass);


--
-- TOC entry 3004 (class 2604 OID 623356)
-- Name: mst_circle circleid; Type: DEFAULT; Schema: mybillmyright; Owner: postgres
--

ALTER TABLE ONLY mybillmyright.mst_circle ALTER COLUMN circleid SET DEFAULT nextval('mybillmyright.mst_circle_circleid_seq'::regclass);


--
-- TOC entry 3005 (class 2604 OID 623367)
-- Name: mst_dept_user userid; Type: DEFAULT; Schema: mybillmyright; Owner: postgres
--

ALTER TABLE ONLY mybillmyright.mst_dept_user ALTER COLUMN userid SET DEFAULT nextval('mybillmyright.mst_dept_user_userid_seq'::regclass);


--
-- TOC entry 3010 (class 2604 OID 623384)
-- Name: mst_division divisionid; Type: DEFAULT; Schema: mybillmyright; Owner: postgres
--

ALTER TABLE ONLY mybillmyright.mst_division ALTER COLUMN divisionid SET DEFAULT nextval('mybillmyright.mst_division_divisionid_seq'::regclass);


--
-- TOC entry 3011 (class 2604 OID 623395)
-- Name: mst_menu menuid; Type: DEFAULT; Schema: mybillmyright; Owner: postgres
--

ALTER TABLE ONLY mybillmyright.mst_menu ALTER COLUMN menuid SET DEFAULT nextval('mybillmyright.mst_menu_menuid_seq'::regclass);


--
-- TOC entry 3012 (class 2604 OID 623403)
-- Name: mst_menu_mapping menuid; Type: DEFAULT; Schema: mybillmyright; Owner: postgres
--

ALTER TABLE ONLY mybillmyright.mst_menu_mapping ALTER COLUMN menuid SET DEFAULT nextval('mybillmyright.mst_menu_mapping_menuid_seq'::regclass);


--
-- TOC entry 3013 (class 2604 OID 623414)
-- Name: mst_role roleid; Type: DEFAULT; Schema: mybillmyright; Owner: postgres
--

ALTER TABLE ONLY mybillmyright.mst_role ALTER COLUMN roleid SET DEFAULT nextval('mybillmyright.mst_role_roleid_seq'::regclass);


--
-- TOC entry 3014 (class 2604 OID 623422)
-- Name: mst_roleaction roleactionid; Type: DEFAULT; Schema: mybillmyright; Owner: postgres
--

ALTER TABLE ONLY mybillmyright.mst_roleaction ALTER COLUMN roleactionid SET DEFAULT nextval('mybillmyright.mst_roleaction_roleactionid_seq'::regclass);


--
-- TOC entry 3015 (class 2604 OID 623430)
-- Name: mst_roletype roletypeid; Type: DEFAULT; Schema: mybillmyright; Owner: postgres
--

ALTER TABLE ONLY mybillmyright.mst_roletype ALTER COLUMN roletypeid SET DEFAULT nextval('mybillmyright.mst_roletype_roletypeid_seq'::regclass);


--
-- TOC entry 3000 (class 2604 OID 620564)
-- Name: mst_user userid; Type: DEFAULT; Schema: mybillmyright; Owner: postgres
--

ALTER TABLE ONLY mybillmyright.mst_user ALTER COLUMN userid SET DEFAULT nextval('mybillmyright.mst_user_userid_seq'::regclass);


--
-- TOC entry 3016 (class 2604 OID 623438)
-- Name: mst_user_charge userchargeid; Type: DEFAULT; Schema: mybillmyright; Owner: postgres
--

ALTER TABLE ONLY mybillmyright.mst_user_charge ALTER COLUMN userchargeid SET DEFAULT nextval('mybillmyright.mst_user_charge_userchargeid_seq'::regclass);


--
-- TOC entry 3019 (class 2604 OID 623466)
-- Name: mst_userlog userlogid; Type: DEFAULT; Schema: mybillmyright; Owner: postgres
--

ALTER TABLE ONLY mybillmyright.mst_userlog ALTER COLUMN userlogid SET DEFAULT nextval('mybillmyright.mst_userlog_userlogid_seq'::regclass);


--
-- TOC entry 3001 (class 2604 OID 620566)
-- Name: mst_userlogindetail userloginid; Type: DEFAULT; Schema: mybillmyright; Owner: postgres
--

ALTER TABLE ONLY mybillmyright.mst_userlogindetail ALTER COLUMN userloginid SET DEFAULT nextval('mybillmyright.mst_userlogindetail_userloginid_seq'::regclass);


--
-- TOC entry 3017 (class 2604 OID 623446)
-- Name: mst_usertype usertypeid; Type: DEFAULT; Schema: mybillmyright; Owner: postgres
--

ALTER TABLE ONLY mybillmyright.mst_usertype ALTER COLUMN usertypeid SET DEFAULT nextval('mybillmyright.mst_usertype_usertypeid_seq'::regclass);


--
-- TOC entry 3018 (class 2604 OID 623454)
-- Name: mst_zone zoneid; Type: DEFAULT; Schema: mybillmyright; Owner: postgres
--

ALTER TABLE ONLY mybillmyright.mst_zone ALTER COLUMN zoneid SET DEFAULT nextval('mybillmyright.mst_zone_zoneid_seq'::regclass);


--
-- TOC entry 3002 (class 2604 OID 620567)
-- Name: test id; Type: DEFAULT; Schema: mybillmyright; Owner: postgres
--

ALTER TABLE ONLY mybillmyright.test ALTER COLUMN id SET DEFAULT nextval('mybillmyright.test_id_seq'::regclass);


--
-- TOC entry 2989 (class 2604 OID 585139)
-- Name: test id; Type: DEFAULT; Schema: public; Owner: nursec
--

ALTER TABLE ONLY public.test ALTER COLUMN id SET DEFAULT nextval('public.test_id_seq'::regclass);


--
-- TOC entry 3191 (class 0 OID 620499)
-- Dependencies: 184
-- Data for Name: billdetail; Type: TABLE DATA; Schema: mybillmyright; Owner: postgres
--

COPY mybillmyright.billdetail (billdetailid, userid, configcode, mobilenumber, billnumber, billdate, shopname, billamount, statecode, distcode, filename, fileextension, filesize, mimetype, filepath, acknumber, uploadedby, uploadedon, statusflag) FROM stdin;
185	85	03	9487687827	0000007877	2023-02-14	Sarava Store	78776787	TN	610	1dc5c65432e651b4e58be36ab2605def_screencapture-10-163-19-176-nursecounsil-updating-Etransfer-approved-details-2023-02-16-10_51_31.pdf	\N	322.80 KB	application/pdf	2023/610/02/1dc5c65432e651b4e58be36ab2605def_screencapture-10-163-19-176-nursecounsil-updating-Etransfer-approved-details-2023-02-16-10_51_31.pdf	5978272023021487778776787	85	2023-03-27 15:46:10	N
186	83	03	9159698082	0000420067	2023-02-10	Saravana store	5000	TN	586	3a5712d58ad8f83c969a34f2cb5f8514_		616.67 KB	image/jpeg	2023/586/02/3a5712d58ad8f83c969a34f2cb5f8514_	202211/586/082/067/000001	83	2023-03-27 15:46:58	N
184	85	03	9487687827	0000000200	2023-02-09	saravana	20000	TN	610	a67690e74bf36fefc8b8bd0e627cba80_form11.pdf		472.77 KB	application/pdf	2023/610/02/a67690e74bf36fefc8b8bd0e627cba80_form11.pdf	5978272023020920000020000	85	2023-03-27 15:46:54	Y
188	83	02	9159698082	0000056985	2023-02-17	pothys	3880	TN	610	aa0138f977a2d29a72a6fafe983a9a49_		163.61 KB	image/jpeg	2023/610/02/aa0138f977a2d29a72a6fafe983a9a49_	202210/610/378/985/000001	83	2023-03-27 15:50:17	N
199	85	03	9487687827	0000000434	2023-02-15	test	45	TN	610	dcf8e081b6a72ba95b5f5b6c415f99d2_screencapture-10-163-19-176-nursecounsil-updating-Etransfer-approved-details-2023-02-16-10_51_31.pdf	\N	322.80 KB	application/pdf	2023/610/02/dcf8e081b6a72ba95b5f5b6c415f99d2_screencapture-10-163-19-176-nursecounsil-updating-Etransfer-approved-details-2023-02-16-10_51_31.pdf	202303/597/827/434/543446	85	2023-03-27 18:00:33	N
187	85	03	9487687827	0000000521	2023-02-16	Pothys	56000	TN	610	240131568399f8fa26e1a10ccee606c0_sivananthan_cv.pdf	\N	136.58 KB	application/pdf	2023/610/02/240131568399f8fa26e1a10ccee606c0_sivananthan_cv.pdf	5978272023021652100056000	85	2023-03-27 15:51:29	Y
189	83	02	9159698082	0000067896	2023-02-17	chennai silks	2500	TN	610	3715662b7781a11426f852da2a43c70d_		75.16 KB	image/jpeg	2023/610/02/3715662b7781a11426f852da2a43c70d_	202210/610/378/896/000001	83	2023-03-27 16:03:50	N
190	83	03	9159698082	0000001456	2023-02-15	GH	8000	TN	586	201cfb15ad4ba78e696f98f083ed31b6_		112.60 KB	image/jpeg	2023/586/02/201cfb15ad4ba78e696f98f083ed31b6_	202211/586//456/000001	83	2023-03-27 16:46:13	N
191	83	03	9159698082	0000000789	2023-02-15	Amazon	5000	TN	586	a68cec46ec7999c46fddd993df4f962b_		145.34 KB	image/jpeg	2023/586/02/a68cec46ec7999c46fddd993df4f962b_	202211/586/082/789/000001	83	2023-03-27 16:54:01	N
192	83	03	9159698082	0000000147	2023-02-08	poli	500	TN	586	ff396b9e57e6db6299a30a3b974fa2e8_		112.60 KB	image/jpeg	2023/586/02/ff396b9e57e6db6299a30a3b974fa2e8_	202211/586/082/147/000001	83	2023-03-27 17:01:06	N
193	83	03	9159698082	0000845745	2023-02-16	GH2	2582	TN	586	eb5511713aa381d9e29fcd0f32ea6892_		112.60 KB	image/jpeg	2023/586/02/eb5511713aa381d9e29fcd0f32ea6892_	202211/586/082/745/000001	83	2023-03-27 17:04:52	N
194	83	03	9159698082	0000000045	2023-02-09	poi	5000	TN	586	b4c930beff3b43467ce743a835553db1_		112.60 KB	image/jpeg	2023/586/02/b4c930beff3b43467ce743a835553db1_	202211/586/082/045/000001	83	2023-03-27 17:15:05	N
195	83	03	9159698082	0000000158	2023-02-01	kill	1400	TN	586	c57180dafe72690d8c6b4e3ce1c2a486_		97.13 KB	image/jpeg	2023/586/02/c57180dafe72690d8c6b4e3ce1c2a486_	202211/586/082/158/000001	83	2023-03-27 17:17:30	N
196	83	03	9159698082	0845878554	2023-02-17	Asika Jewellery	2500	TN	586	27f1e60a78958ae5db1d03b87966c3a8_		112.60 KB	image/jpeg	2023/586/02/27f1e60a78958ae5db1d03b87966c3a8_	202211/586/082/554/000001	83	2023-03-27 17:20:32	N
197	83	03	9159698082	0000789455	2023-02-18	SIva Infotech	2500	TN	586	df3145e34fcaa169033d41f224cd07f5_		112.60 KB	image/jpeg	2023/586/02/df3145e34fcaa169033d41f224cd07f5_	202211/586/082/455/000001	83	2023-03-27 17:22:19	N
200	85	03	9487687827	0000000433	2023-02-15	test	45	TN	610	6333bb3a9cd3e8c029128c4744b51386_screencapture-10-163-19-176-nursecounsil-updating-Etransfer-approved-details-2023-02-16-10_51_31.pdf	\N	322.80 KB	application/pdf	2023/610/02/6333bb3a9cd3e8c029128c4744b51386_screencapture-10-163-19-176-nursecounsil-updating-Etransfer-approved-details-2023-02-16-10_51_31.pdf	202303/597/827/433/851858	85	2023-03-27 18:01:17	N
201	85	03	9487687827	0000003424	2023-02-09	test	45	TN	610	5d0c3010cc844b667b8a720c2bc69e11_TNeGA - Directorate of Medical and Rural Health Services V1.0.pdf	\N	2.87 MB	application/pdf	2023/610/02/5d0c3010cc844b667b8a720c2bc69e11_TNeGA - Directorate of Medical and Rural Health Services V1.0.pdf	202303/597/827/424/694731	85	2023-03-27 18:01:37	N
206	83	03	9159698082	0000006616	2023-02-17	Raman and Raman	12000	TN	586	d3a586200d8e557a34def4ff1da27ad8_		399.94 KB	image/jpeg	2023/586/02/d3a586200d8e557a34def4ff1da27ad8_	202211/586/082/616/000001	83	2023-03-27 19:12:48	N
203	83	03	9159698082	0000005689	2023-02-14	Jos Alukas	5000	TN	586	22f6915c027b71c2d9ae3825765194ca_		112.60 KB	image/jpeg	2023/586/02/22f6915c027b71c2d9ae3825765194ca_	202211/586/082/689/000001	83	2023-03-27 18:17:27	N
207	86	03	6383839415	0000002200	2023-02-13	Pratap pawn broker tvm	15310	TN	586	8f671dbd7e893ea0fd472dfba6ff28ee_		520.40 KB	image/jpeg	2023/586/02/8f671dbd7e893ea0fd472dfba6ff28ee_	202211/586/082/200/000001	86	2023-03-27 21:04:23	N
205	83	03	9159698082	0005698745	2023-02-15	Nic Private Ltd	5000	TN	586	aa470685cd2fe332f7f9a554c4d7be3b_		112.60 KB	image/jpeg	2023/586/02/aa470685cd2fe332f7f9a554c4d7be3b_	202211/586/082/745/000001	83	2023-03-27 18:31:55	N
198	83	03	9159698082	0000000442	2023-02-22	Cotton house thiruvanmiyur	1837	TN	586	c38c37952f0b4bedd4315c519a8713a5_		181.82 KB	image/jpeg	2023/586/02/c38c37952f0b4bedd4315c519a8713a5_	202211/586/082/442/000001	83	2023-03-27 20:56:17	N
209	86	02	6383839415	0000000210	2023-02-09	R.Mukesh kumar	24000	TN	610	89779dd94e4ed123f4a4d63d5d9143d9_		174.02 KB	image/jpeg	2023/610/02/89779dd94e4ed123f4a4d63d5d9143d9_	202210/610/415/210/000001	86	2023-03-27 21:07:45	N
202	83	03	9159698082	0000005689	2023-02-22	Kotak Mahindra	9800	TN	586	de2fdaf236510e80b03a11a91b12584a_		149.27 KB	image/jpeg	2023/586/02/de2fdaf236510e80b03a11a91b12584a_	202211/586/082/689/000001	83	2023-03-27 18:34:37	N
208	86	03	6383839415	0000000124	2023-02-25	Mukesh kumar	7500	TN	586	0d6bab3cf6e8361e0274dac73fdc5840_		176.70 KB	image/jpeg	2023/586/02/0d6bab3cf6e8361e0274dac73fdc5840_	202211/586/082/124/000001	86	2023-03-27 21:06:18	N
210	86	02	6383839415	0000002235	2023-02-16	Pratap pawn broker	8000	TN	610	b00209719fba54ff070eff82793865ba_		178.71 KB	image/jpeg	2023/610/02/b00209719fba54ff070eff82793865ba_	202210/610/415/235/000001	86	2023-03-27 21:09:06	N
211	85	03	9487687827	0000002803	2023-02-15	test shop	343	TN	610	635b947863b3988dcd2f390a1ff24d80_Pensioner_Portal_Help_File.pdf	\N	488.67 KB	application/pdf	2023/610/02/635b947863b3988dcd2f390a1ff24d80_Pensioner_Portal_Help_File.pdf	202303/597/827/803/160387	85	2023-03-28 10:31:45	N
204	83	03	9159698082	0000000529	2023-02-28	Cotton House	1717	TN	586	16d21fb0c04242d4e953713a5ee7418d_		178.91 KB	image/jpeg	2023/586/02/16d21fb0c04242d4e953713a5ee7418d_	202211/586/082/529/000001	83	2023-03-27 20:57:05	Y
212	85	03	9487687827	0000002843	2023-02-15	test shop	343	TN	610	88624b82db5b78f8690cac9923d91b1e_Pensioner_Portal_Help_File.pdf	\N	488.67 KB	application/pdf	2023/610/02/88624b82db5b78f8690cac9923d91b1e_Pensioner_Portal_Help_File.pdf	202303/597/827/843/869020	85	2023-03-28 10:31:58	N
213	85	03	9487687827	0000123131	2023-02-15	test shop	343	TN	610	a316dc358f0847f31cf4339d149dbebc_Pensioner_Portal_Help_File.pdf	\N	488.67 KB	application/pdf	2023/610/02/a316dc358f0847f31cf4339d149dbebc_Pensioner_Portal_Help_File.pdf	202303/597/827/131/380931	85	2023-03-28 10:57:34	N
214	85	03	9487687827	0000008988	2023-02-21	siva tex	8988	TN	610	85df851cc9d3aeebc81d6289dee0276e	\N	6.27 KB	image/jpeg	2023/610/02/85df851cc9d3aeebc81d6289dee0276e	202303/597/827/988/261706	85	2023-03-28 11:22:15	N
217	87	02	9080076157	0000000773	2023-01-14	siva tex	10000	TN	610	ba930a7218b324ea74f81570f025a446_		32.86 KB	image/jpeg	2023/610/02/ba930a7218b324ea74f81570f025a446_	202210/610/157/773/000001	87	2023-03-28 14:57:22	Y
215	87	03	9080076157	0000000560	2023-02-16	Lalitha	50000	TN	610	8d1cb20bdf848510afff96b636d98ab1	\N	106.14 KB	image/jpeg	2023/610/02/8d1cb20bdf848510afff96b636d98ab1	202303/610/157/560/736450	87	2023-03-28 15:41:15	N
219	87	03	9080076157	0000000123	2023-02-01	guhan	500	TN	586	05acd24c395a8f665cd1af7820686c71_		45.86 KB	image/jpeg	2023/586/02/05acd24c395a8f665cd1af7820686c71_	202211/586/082/123/000001	87	2023-03-28 17:13:08	Y
218	87	03	9080076157	0000000123	2023-02-01	guhan	500	TN	586	79459c6de62a2628957bb111b9344b6f	\N	239.29 KB	application/pdf	2023/586/02/79459c6de62a2628957bb111b9344b6f	202303/610/157/123/947097	87	2023-03-28 17:16:17	Y
\.


--
-- TOC entry 3205 (class 0 OID 623345)
-- Dependencies: 198
-- Data for Name: mst_charge; Type: TABLE DATA; Schema: mybillmyright; Owner: postgres
--

COPY mybillmyright.mst_charge (chargeid, chargecode, chargedescription, divisioncode, zonecode, configcode, statusflag, createdby, updatedby, createdon, updatedon, roleid, distcode, circleid, roletypecode, roleactioncode) FROM stdin;
1	01	Nic Admin	\N	\N	\N	Y	\N	\N	\N	\N	13	\N	\N	01	01
2	\N	Citizen	\N	\N	\N	\N	\N	\N	\N	\N	20	\N	\N	06	06
3	\N	ADC	\N	\N	\N	\N	7	\N	2023-03-24 13:19:25.36509	\N	26	\N	\N	02	02
4	\N	aaaaa	04	\N	\N	\N	7	\N	2023-03-27 16:09:29.217433	\N	27	568	\N	03	03
5	\N	AC Manali	04	05	\N	\N	7	\N	2023-03-27 16:44:34.611987	\N	30	568	18	05	05
\.


--
-- TOC entry 3207 (class 0 OID 623353)
-- Dependencies: 200
-- Data for Name: mst_circle; Type: TABLE DATA; Schema: mybillmyright; Owner: postgres
--

COPY mybillmyright.mst_circle (circleid, circlecode, circlename, divisioncode, zonecode, distcode, state_code, status_flag, createdby, createdon, updatedby, updatedon) FROM stdin;
1	01	Joint Commissioner(CS)	01	01	568	33	\N	\N	\N	\N	\N
2	02	Joint Commissioner(IT)	01	01	568	33	\N	\N	\N	\N	\N
3	03	Joint Commissioner(ST), Advance Ruling Authority	01	01	568	33	\N	\N	\N	\N	\N
4	04	Joint Commissioner(CT),Large Tax Payers Unit	02	01	568	33	\N	\N	\N	\N	\N
5	05	Deputy Commissioner(CT),LTU-I	02	01	568	33	\N	\N	\N	\N	\N
6	06	Deputy Commissioner(CT),LTU-II	02	01	568	33	\N	\N	\N	\N	\N
7	07	Deputy Commissioner(CT),LTU-III	02	01	568	33	\N	\N	\N	\N	\N
8	08	Deputy Commissioner(CT),LTU-IV	02	01	568	33	\N	\N	\N	\N	\N
9	13	Assistant Commissioner(CT),Chennai(North)	03	02	568	33	\N	\N	\N	\N	\N
10	09	Deputy Commissioner(CT),Zone-I	03	02	568	33	\N	\N	\N	\N	\N
11	10	Assistant Commissioner(CT),Harbour	03	02	568	33	\N	\N	\N	\N	\N
12	11	Assistant Commissioner(CT),Vaallar Nagar	03	03	568	33	\N	\N	\N	\N	\N
13	12	Assistant Commissioner(CT),Chennai(North)	03	03	568	33	\N	\N	\N	\N	\N
14	17	Joint Commissioner(CT),Chennai(Central)	03	04	568	33	\N	\N	\N	\N	\N
15	18	Deputy Commissioner(CT),Zone-IV	03	04	568	33	\N	\N	\N	\N	\N
16	14	Assistant Commissioner(CT),Annasalai	04	05	568	33	\N	\N	\N	\N	\N
17	15	Assistant Commissioner(CT),Kodungaiyur	04	05	568	33	\N	\N	\N	\N	\N
18	16	Assistant Commissioner(CT),Manali	04	05	568	33	\N	\N	\N	\N	\N
\.


--
-- TOC entry 3193 (class 0 OID 620508)
-- Dependencies: 186
-- Data for Name: mst_config; Type: TABLE DATA; Schema: mybillmyright; Owner: postgres
--

COPY mybillmyright.mst_config (configid, schemecode, configcode, statecode, distcode, minimumbillamt, prizeamount, billentrystartdate, billentryenddate, billpurchasestartdate, billpurchaseenddate, billdrawdate, yymm, statusflag, createdby, createdon, updatedby, updatedon) FROM stdin;
1	02	02	TN	610	10	500	2023-01-01 00:00:00	2023-01-27 00:00:00	2023-02-01 00:00:00	2023-02-28 00:00:00	\N	2210	\N	\N	\N	\N	\N
2	03	03	TN	586	10	2000	2023-03-01 00:00:00	2023-03-30 00:00:00	2023-02-01 00:00:00	2023-02-28 00:00:00	2021-07-26 20:17:30.696395	2211	1	1	2021-07-26 20:17:30.696395	1	2021-07-26 20:17:30.696395
\.


--
-- TOC entry 3194 (class 0 OID 620511)
-- Dependencies: 187
-- Data for Name: mst_configlog; Type: TABLE DATA; Schema: mybillmyright; Owner: postgres
--

COPY mybillmyright.mst_configlog (configlogid, configid, schemecode, configcode, statecode, distcode, minimumbillamt, prizeamount, billentrystartdate, billentryenddate, billpurchasestartdate, billpurchaseenddate, billdrawdate, yymm, statusflag, createdby, createdon, updatedby, updatedon) FROM stdin;
\.


--
-- TOC entry 3209 (class 0 OID 623364)
-- Dependencies: 202
-- Data for Name: mst_dept_user; Type: TABLE DATA; Schema: mybillmyright; Owner: postgres
--

COPY mybillmyright.mst_dept_user (userid, email, pwd, name, mobilenumber, statecode, distcode, createdby, createdon, updatedby, updatedon, statusflag, profile_update, divisioncode, zonecode, circleid, dateofbirth, nodal, lott_executor, empid, roletypecode) FROM stdin;
7	nicadmin@gmail.com	098f6bcd4621d373cade4e832627b4f6	Nic Admin	9876543210	TN	\N	1	\N	1	\N	t	\N	\N	\N	\N	\N	N	N	\N	01
1	xx1@gmail.com	cc03e747a6afbbcbf8be7668acfebee5	Rajan	9885632563	TN	568	7	2023-03-27 16:10:49.941495	1	\N	t	Y	04	\N	\N	1970-03-25	\N	\N	5560	03
2	test@gmail.com	cc03e747a6afbbcbf8be7668acfebee5	Kumar	1234567890	TN	568	7	2023-03-27 16:46:47.927817	1	\N	t	Y	04	05	18	1988-03-23	\N	\N	12345	05
\.


--
-- TOC entry 3195 (class 0 OID 620514)
-- Dependencies: 188
-- Data for Name: mst_district; Type: TABLE DATA; Schema: mybillmyright; Owner: postgres
--

COPY mybillmyright.mst_district (distid, distcode, statecode, distename, flag, createdon, createdby, updatedby, updatedon) FROM stdin;
123	589	TN	Tiruvallur	0	2022-10-14 14:45:37	1	1	2022-10-14 14:45:37
98	568	TN	Chennai	0	2022-10-14 14:45:37	1	1	2022-10-14 14:45:37
104	574	TN	Kanchipuram	0	2022-10-14 14:45:37	1	1	2022-10-14 14:45:37
126	595	TN	Vellore	0	2022-10-14 14:45:37	1	1	2022-10-14 14:45:37
101	571	TN	Dharmapuri	0	2022-10-14 14:45:37	1	1	2022-10-14 14:45:37
124	593	TN	Tiruvannamalai	0	2022-10-14 14:45:37	1	1	2022-10-14 14:45:37
127	596	TN	Viluppuram	0	2022-10-14 14:45:37	1	1	2022-10-14 14:45:37
115	584	TN	Salem	0	2022-10-14 14:45:37	1	1	2022-10-14 14:45:37
110	580	TN	Namakkal	0	2022-10-14 14:45:37	1	1	2022-10-14 14:45:37
103	573	TN	Erode	0	2022-10-14 14:45:37	1	1	2022-10-14 14:45:37
111	587	TN	Nilgiris	0	2022-10-14 14:45:37	1	1	2022-10-14 14:45:37
99	569	TN	Coimbatore	0	2022-10-14 14:45:37	1	1	2022-10-14 14:45:37
102	572	TN	Dindigul	0	2022-10-14 14:45:37	1	1	2022-10-14 14:45:37
106	576	TN	Karur	0	2022-10-14 14:45:37	1	1	2022-10-14 14:45:37
120	591	TN	Tiruchirappalli	0	2022-10-14 14:45:37	1	1	2022-10-14 14:45:37
112	581	TN	Perambalur	0	2022-10-14 14:45:37	1	1	2022-10-14 14:45:37
97	610	TN	Ariyalur	0	2022-10-14 14:45:37	1	1	2022-10-14 14:45:37
100	570	TN	Cuddalore	0	2022-10-14 14:45:37	1	1	2022-10-14 14:45:37
109	579	TN	Nagapattinam	0	2022-10-14 14:45:37	1	1	2022-10-14 14:45:37
125	590	TN	Tiruvarur	0	2022-10-14 14:45:37	1	1	2022-10-14 14:45:37
117	586	TN	Thanjavur	0	2022-10-14 14:45:37	1	1	2022-10-14 14:45:37
113	582	TN	Pudukkottai	0	2022-10-14 14:45:37	1	1	2022-10-14 14:45:37
116	585	TN	Sivaganga	0	2022-10-14 14:45:37	1	1	2022-10-14 14:45:37
108	578	TN	Madurai	0	2022-10-14 14:45:37	1	1	2022-10-14 14:45:37
118	588	TN	Theni	0	2022-10-14 14:45:37	1	1	2022-10-14 14:45:37
128	597	TN	Virudhunagar	0	2022-10-14 14:45:37	1	1	2022-10-14 14:45:37
114	583	TN	Ramanathapuram	0	2022-10-14 14:45:37	1	1	2022-10-14 14:45:37
119	594	TN	Thoothukudi (Tuticorin)	0	2022-10-14 14:45:37	1	1	2022-10-14 14:45:37
121	592	TN	Tirunelveli	0	2022-10-14 14:45:37	1	1	2022-10-14 14:45:37
105	575	TN	Kanyakumari	0	2022-10-14 14:45:37	1	1	2022-10-14 14:45:37
107	577	TN	Krishnagiri	0	2022-10-14 14:45:37	1	1	2022-10-14 14:45:37
122	634	TN	Tiruppur	0	2022-10-14 14:45:37	1	1	2022-10-14 14:45:37
\.


--
-- TOC entry 3211 (class 0 OID 623381)
-- Dependencies: 204
-- Data for Name: mst_division; Type: TABLE DATA; Schema: mybillmyright; Owner: postgres
--

COPY mybillmyright.mst_division (divisionid, divisioncode, divisionsname, divisionlname, statecode, statusflag, createdby, createdon, updatedby, updatedon) FROM stdin;
1	01	OOCCT	Office Of the Commissioner of Commerical Taxes	\N	Y	\N	\N	\N	\N
2	02	LTU	Large Taxpayers Unit	\N	Y	\N	\N	\N	\N
3	03	CH(N)	Chennai (North)	\N	Y	\N	\N	\N	\N
4	04	CH(C)	Chennai (Central)	\N	Y	\N	\N	\N	\N
\.


--
-- TOC entry 3213 (class 0 OID 623392)
-- Dependencies: 206
-- Data for Name: mst_menu; Type: TABLE DATA; Schema: mybillmyright; Owner: postgres
--

COPY mybillmyright.mst_menu (menuid, statecode, menuname, levelid, parentid, menuurl, status, createdby, createdon, updatedby, updatedon, key, order_id) FROM stdin;
3	\N	Billing Details	1	\N	Mybill/billing_details	Y	1	2023-03-02 04:07:44.687977	\N	\N	billing_details	\N
4	\N	My Bill	2	3	Mybill/mybill	Y	1	2023-03-02 04:08:54.849724	\N	\N	mybill	\N
5	\N	Bill History	2	3	Mybill/bill_history	Y	1	2023-03-02 04:09:36.010054	\N	\N	bill_history	\N
6	\N	Account Details	1	\N	Mybill/Account Details	Y	1	2023-03-02 04:12:19.782143	\N	\N	account_details	\N
7	\N	Profile	2	6	Mybill/profile	Y	1	2023-03-02 04:14:08.717483	\N	\N	profile	\N
1	\N	User Management	1	0	Mybill/UserManagment	Y	1	2023-03-01 21:39:53.901979	1	2023-03-02 04:16:28.2884	user_management	\N
2	\N	Create User	2	1	Mybill/create_user	Y	1	2023-03-01 21:46:32.956883	1	2023-03-02 04:16:51.976141	create_user	\N
9	\N	create charge	2	1	Mybill/create_charge	Y	1	2023-03-02 04:17:51.85518	\N	\N	create_charge	\N
10	\N	Assign Charge	2	1	Mybill/assign_charge	Y	1	2023-03-02 04:19:13.867966	\N	\N	assign_charge	\N
8	\N	Change Password	2	6	Mybill/change_password	Y	1	2023-03-02 04:16:51.088822	1	2023-03-02 04:19:38.008784	change_password	\N
13	\N	Dashboard	1	0	Mybill/citizen_dashboard	Y	1	2023-03-02 04:33:18.139899	1	2023-03-02 04:33:33.034963	citizen_dash	\N
14	\N	Dashboard	1	\N	Mybill/dashboard	Y	1	2023-03-02 04:34:04.1476	\N	\N	dashboard	\N
15	\N	Menu & Roles	1	\N	Mybill	Y	1	2023-03-03 03:12:11.67196	\N	\N	menu_role	\N
16	\N	Menus	2	15	Mybill/menu	Y	1	2023-03-03 03:12:35.614851	\N	\N	menu	\N
17	\N	Roles	2	15	Mybill/role	Y	1	2023-03-03 03:12:57.430924	\N	\N	role	\N
18	\N	Manage Role	2	15	Mybill/manage_role	Y	1	2023-03-05 06:09:02.012195	1	2023-03-05 06:46:51.820469	manage_role	\N
11	\N	Unassign Charge	2	1	Mybill/unassign_charge	N	1	2023-03-02 04:19:47.872702	\N	\N	unassign_charge	\N
12	\N	Additional Charge	2	1	Mybill/additional_charge	N	1	2023-03-02 04:20:23.04084	\N	\N	additional_charge	\N
19	\N	View User	2	1	Mybill/view_user	Y	1	2023-03-20 05:47:57.974374	\N	\N	view_user	\N
20	\N	View Charge	2	1	Mybill/view_charge	Y	1	2023-03-20 05:48:24.14594	\N	\N	view_charge	\N
21	\N	Confirguration	1	\N	Mybill/configuration	Y	1	2023-03-21 03:44:15.125496	\N	\N	configuration	\N
22	\N	Settings	2	21	Mybill/configuration_settings	Y	1	2023-03-21 03:44:42.809417	\N	\N	settings	\N
\.


--
-- TOC entry 3215 (class 0 OID 623400)
-- Dependencies: 208
-- Data for Name: mst_menu_mapping; Type: TABLE DATA; Schema: mybillmyright; Owner: postgres
--

COPY mybillmyright.mst_menu_mapping (menuid, roleid, control_json) FROM stdin;
29	30	{"1": ["8", "7", 14]}
30	31	{"1": ["10", "8", "9", "2", "7", "20", "19", 14]}
26	26	{"1": ["10", "8", "9", "2", "16", "7", "17", "22", "20", "19", 14]}
13	13	{"1": ["10", "9", "2", "18", "16", "17", "22", "20", "19", 14]}
27	27	{"1": ["10", "8", "9", "2", "18", "7", "22", 14]}
20	20	{"1": ["5", "8", "4", "7", 13]}
\.


--
-- TOC entry 3217 (class 0 OID 623411)
-- Dependencies: 210
-- Data for Name: mst_role; Type: TABLE DATA; Schema: mybillmyright; Owner: postgres
--

COPY mybillmyright.mst_role (roleid, statecode, rolesname, rolelname, status, createdby, createdon, updatedby, updatedon, usertypecode, roletypecode, roleactioncode) FROM stdin;
13	33	Nic Admin	\N	Y	1	2023-03-16 00:34:17.622117	\N	\N	02	01	01
20	33	Citizen	\N	Y	1	2023-03-19 21:57:40.414574	\N	\N	01	06	06
26	33	ADC	\N	Y	1	2023-03-19 23:47:39.125557	\N	\N	02	02	02
27	33	JC 	\N	Y	1	2023-03-20 00:18:53.439474	\N	\N	02	03	03
30	33	AC	\N	Y	1	2023-03-20 04:33:28.672021	\N	\N	02	05	05
31	33	DC	\N	Y	1	2023-03-20 21:51:05.569915	\N	\N	02	04	04
\.


--
-- TOC entry 3219 (class 0 OID 623419)
-- Dependencies: 212
-- Data for Name: mst_roleaction; Type: TABLE DATA; Schema: mybillmyright; Owner: postgres
--

COPY mybillmyright.mst_roleaction (roleactionid, roleactioncode, roleactionsname, roleactionlname, statusflag, createdby, createdon, updatedby, updatedon, roletypecode) FROM stdin;
1	02	ADC	Additional Commissioner 	Y	1	23:19:18.631824	1	23:19:18.631824	02
2	03	JC	Joint Commissioner 	Y	1	23:19:41.38166	1	23:19:41.38166	03
3	04	DC	Deputy Commissioner 	Y	1	23:20:02.468652	1	23:20:02.468652	04
4	05	AC	Assistant Commissioner	Y	1	23:20:21.707182	1	23:20:21.707182	05
5	06	C	Citizen	Y	1	23:20:38.521665	1	23:20:38.521665	06
6	01	Nic	Nic Admin	\N	\N	\N	\N	\N	01
\.


--
-- TOC entry 3221 (class 0 OID 623427)
-- Dependencies: 214
-- Data for Name: mst_roletype; Type: TABLE DATA; Schema: mybillmyright; Owner: postgres
--

COPY mybillmyright.mst_roletype (roletypeid, roletypecode, roletypelname, statusflag, createdby, createdon, updatedby, updatedon, usertypecode) FROM stdin;
2	02	Additional Commissioner	Y	1	2023-03-15 22:32:09.473697	1	2023-03-15 22:32:09.473697	02
3	03	Joint Commissioner	Y	1	2023-03-15 22:32:33.078455	1	2023-03-15 22:32:33.078455	02
5	05	Assitant Commissioner	Y	1	2023-03-15 22:32:50.256706	1	2023-03-15 22:32:50.256706	02
1	01	Nic Admin	N	1	2023-03-15 22:31:31.40468	1	2023-03-15 22:31:31.40468	02
6	06	Employee	Y	1	2023-03-15 22:33:18.240964	1	2023-03-15 22:33:18.240964	01
4	04	Deputy Commissioner	Y	1	2023-03-15 22:32:39.861276	1	2023-03-15 22:32:39.861276	02
\.


--
-- TOC entry 3196 (class 0 OID 620517)
-- Dependencies: 189
-- Data for Name: mst_scheme; Type: TABLE DATA; Schema: mybillmyright; Owner: postgres
--

COPY mybillmyright.mst_scheme (schemeid, schemecode, schemesname, schemelname, minimumbillamt, prizeamount, billentrystartdate, billentryenddate, billpurchasestartdate, billpurchaseenddate, billdrawdate, finyear, statusflag, yymm, configstate_dist, createdby, createdon, updatedby, updatedon) FROM stdin;
1	01	MyBill	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	202210	1	\N	\N	\N	\N
\.


--
-- TOC entry 3197 (class 0 OID 620520)
-- Dependencies: 190
-- Data for Name: mst_state; Type: TABLE DATA; Schema: mybillmyright; Owner: postgres
--

COPY mybillmyright.mst_state (stateid, statecode, stateename, statetname, stateut, flag, createdon, createdby, updatedby, updatedon) FROM stdin;
49	TN	Tamil Nadu	தமிழ்நாடு	0	0	2022-10-14 14:45:37	1	1	2022-10-14 14:45:37
\.


--
-- TOC entry 3198 (class 0 OID 620523)
-- Dependencies: 191
-- Data for Name: mst_user; Type: TABLE DATA; Schema: mybillmyright; Owner: postgres
--

COPY mybillmyright.mst_user (userid, schemecode, email, pwd, name, mobilenumber, statecode, distcode, ipaddress, deviceid, addr1, addr2, pincode, createdby, createdon, updatedby, updatedon, statusflag, profile_update, chargeid, roleid, roletypecode) FROM stdin;
80	01	test@gmail.com	827ccb0eea8a706c4c34a16891f84e7b	Rahmath	9884778378	TN	610	127.0.0.1	W	test test test	test test test	600012	1	2023-02-21 01:56:42	80	2023-02-20 16:59:06.947114	t	Y	\N	\N	\N
81	01	Cherna@kkk.cd	b075d9af3f15e709616e0084376f0219	Siva	6666666666	TN	572	10.163.19.153	W	sdasasdasdasdas	asdasdasasdas	600000	1	2023-02-21 21:53:19	81	2023-02-21 12:53:51.617895	t	Y	\N	\N	\N
84	01	rahamath.chennai@gmail.com	a3876fafbc8b9b9d3820b6e3a610e3d2	Nisha	9884253079	TN	568	192.0.0.177	M	Address 1	Address 2	600000	1	2023-03-21 17:21:16	1	2023-03-21 17:21:16	t	\N	\N	\N	\N
79	01	sivaeceerd@gmail.com	0e7517141fb53f21ee439b355b5a1d0a	siva	8148958988	TN	610	127.0.0.1	W	karungal palayam	cauvery road	638003	1	2023-02-17 19:40:37	79	2023-02-20 16:02:34.733488	t	Y	\N	\N	\N
86	01	anitha96880@gmail.com	d9aa68ff2a28a157eeb3ad26362adbe4	Anita	6383839415	TN	610	192.0.0.177	M	main road,suthamalli.	Address 2	621804	1	2023-03-26 08:31:49	1	2023-03-26 08:31:49	t	\N	\N	\N	\N
85	01	swathinagarajann99@gmail.com	e801ebc30a494503e7ba8fc001764c8d	swathi	9487687827	TN	597	10.163.19.176	W	kattaiyapuram	virudhunagar	626001	1	2023-03-24 12:36:35	85	2023-03-27 11:44:45.101007	t	Y	2	20	06
83	01	stalingalaxy@gmail.com	0e7517141fb53f21ee439b355b5a1d0a	Stalin Thomas	9159698082	TN	586	192.0.0.177	M	milagay pattam street,vadagarai,kumbakonam(t.k)	Address 2	612201	1	2023-03-10 15:54:07	1	2023-03-10 15:54:07	t	\N	\N	\N	\N
87	01	sivaeceerd@gmail.com	8907fc2282ea176b029fd7819a83dc2f	siva	9080076157	TN	610	192.0.0.177	M	12 Raja St	Annamalaipuram Chennai	600012	1	2023-03-28 11:46:34	87	2023-03-28 17:21:29.569076	t	Y	2	20	06
\.


--
-- TOC entry 3223 (class 0 OID 623435)
-- Dependencies: 216
-- Data for Name: mst_user_charge; Type: TABLE DATA; Schema: mybillmyright; Owner: postgres
--

COPY mybillmyright.mst_user_charge (userchargeid, statecode, userid, divisioncode, zonecode, configcode, charge_from, statusflag, createdby, createdon, updatedby, updatedon, chargeid, roleid, circleid, distcode, roletypecode) FROM stdin;
1	33	7	\N	\N	\N	2023-03-03	Y	\N	\N	\N	\N	1	13	\N	\N	01
2	TN	1	\N	\N	\N	2023-03-27	Y	7	2023-03-27 16:11:15.733143	\N	\N	4	\N	\N	\N	27
3	TN	2	\N	\N	\N	2023-03-27	Y	7	2023-03-27 16:47:18.114984	\N	\N	5	\N	\N	\N	30
\.


--
-- TOC entry 3229 (class 0 OID 623463)
-- Dependencies: 222
-- Data for Name: mst_userlog; Type: TABLE DATA; Schema: mybillmyright; Owner: postgres
--

COPY mybillmyright.mst_userlog (userlogid, userid, schemecode, email, pwd, name, mobilenumber, statusflag, statecode, distcode, ipaddress, deviceid, addr1, adr2, pincode, createdby, createdon, updatedby, updatedon) FROM stdin;
1	85	01	swathinagarajann99@gmail.com	e801ebc30a494503e7ba8fc001764c8d	swathi	9487687827	1	TN	597	10.163.19.176	W	\N	\N	\N	1	2023-03-24 12:36:35	1	2023-03-24 12:36:35
2	85	01	swathinagarajann99@gmail.com	e801ebc30a494503e7ba8fc001764c8d	swathi	9487687827	1	TN	597	10.163.19.176	W	\N	\N	\N	1	2023-03-24 12:36:35	85	2023-03-24 12:55:44.011177
3	85	01	swathinagarajann99@gmail.com	e801ebc30a494503e7ba8fc001764c8d	swathi	9487687827	1	TN	597	10.163.19.176	W	\N	\N	\N	1	2023-03-24 12:36:35	85	2023-03-24 13:21:18.294371
4	85	01	swathinagarajann99@gmail.com	e801ebc30a494503e7ba8fc001764c8d	swathi	9487687827	1	TN	597	10.163.19.176	W	\N	\N	\N	1	2023-03-24 12:36:35	85	2023-03-24 13:21:36.426412
5	87	01	sivaeceerd@gmail.com	8907fc2282ea176b029fd7819a83dc2f	siva	9080076157	1	TN	610	192.0.0.177	M	\N	\N	\N	1	2023-03-28 11:46:34	1	2023-03-28 11:46:34
6	87	01	sivaeceerd@gmail.com	8907fc2282ea176b029fd7819a83dc2f	siva	9080076157	1	TN	610	192.0.0.177	M	\N	\N	\N	1	2023-03-28 11:46:34	87	2023-03-28 11:49:56.429167
\.


--
-- TOC entry 3200 (class 0 OID 620550)
-- Dependencies: 193
-- Data for Name: mst_userlogindetail; Type: TABLE DATA; Schema: mybillmyright; Owner: postgres
--

COPY mybillmyright.mst_userlogindetail (userid, mobilenumber, ipaddress, deviceid, logintime, logouttime, logoutstatus, userloginid) FROM stdin;
79	8148958988	10.163.19.176	W	2023-02-21 17:14:26	2023-02-21 22:17:32.996242	0	101
79	8148958988	10.163.19.176	W	2023-02-20 22:40:52	2023-02-21 22:17:32.996242	0	89
79	8148958988	10.163.19.176	W	2023-02-21 21:50:32	2023-02-21 22:17:32.996242	0	83
79	8148958988	10.163.19.176	W	2023-02-21 21:30:20	2023-02-21 22:17:32.996242	0	80
79	8148958988	10.163.19.176	W	2023-02-21 21:14:14	2023-02-21 22:17:32.996242	0	78
79	8148958988	127.0.0.1	W	2023-02-21 19:24:38	2023-02-21 22:17:32.996242	0	73
79	8148958988	::1	W	2023-02-21 19:44:36	2023-02-21 22:17:32.996242	0	75
79	8148958988	127.0.0.1	W	2023-02-21 19:22:52	2023-02-21 22:17:32.996242	0	71
79	8148958988	127.0.0.1	W	2023-02-21 01:33:37	2023-02-21 22:17:32.996242	0	68
79	8148958988	10.163.19.176	W	2023-02-20 21:34:18	2023-02-21 22:17:32.996242	0	62
79	8148958988	10.163.19.176	W	2023-02-20 21:34:51	2023-02-21 22:17:32.996242	0	64
79	8148958988	127.0.0.1	W	2023-02-20 21:12:48	2023-02-21 22:17:32.996242	0	58
79	8148958988	10.163.19.173	W	2023-02-20 21:20:24	2023-02-21 22:17:32.996242	0	60
79	8148958988	127.0.0.1	W	2023-02-17 19:40:49	2023-02-21 22:17:32.996242	0	13
79	8148958988	127.0.0.1	W	2023-02-17 21:52:36	2023-02-21 22:17:32.996242	0	14
79	8148958988	127.0.0.1	W	2023-02-17 22:23:27	2023-02-21 22:17:32.996242	0	15
79	8148958988	127.0.0.1	W	2023-02-17 23:30:22	2023-02-21 22:17:32.996242	0	16
79	8148958988	127.0.0.1	W	2023-02-17 23:43:42	2023-02-21 22:17:32.996242	0	17
79	8148958988	10.163.19.176	W	2023-02-22 08:40:59	\N	1	102
81	6666666666	10.163.19.153	W	2023-02-21 21:53:30	2023-02-21 12:54:11.256307	0	85
79	8148958988	10.163.19.176	W	2023-02-20 22:48:45	2023-02-21 22:17:32.996242	0	90
79	8148958988	10.163.19.176	W	2023-02-21 21:52:27	2023-02-21 22:17:32.996242	0	84
79	8148958988	::1	W	2023-02-21 19:44:36	2023-02-21 22:17:32.996242	0	74
79	8148958988	127.0.0.1	W	2023-02-21 19:45:17	2023-02-21 22:17:32.996242	0	76
79	8148958988	10.163.19.176	W	2023-02-20 21:34:35	2023-02-21 22:17:32.996242	0	63
79	8148958988	127.0.0.1	W	2023-02-20 21:35:25	2023-02-21 22:17:32.996242	0	65
79	8148958988	10.163.19.176	W	2023-02-18 00:06:20	2023-02-21 22:17:32.996242	0	25
79	8148958988	10.163.19.176	W	2023-02-18 00:13:12	2023-02-21 22:17:32.996242	0	26
79	8148958988	10.163.19.176	W	2023-02-18 02:11:59	2023-02-21 22:17:32.996242	0	27
79	8148958988	10.163.19.176	W	2023-02-18 02:12:11	2023-02-21 22:17:32.996242	0	28
79	8148958988	10.163.19.176	W	2023-02-18 02:12:32	2023-02-21 22:17:32.996242	0	29
79	8148958988	10.163.19.176	W	2023-02-18 02:12:36	2023-02-21 22:17:32.996242	0	30
79	8148958988	10.163.19.176	W	2023-02-18 02:12:55	2023-02-21 22:17:32.996242	0	31
79	8148958988	10.163.19.176	W	2023-02-18 02:12:59	2023-02-21 22:17:32.996242	0	32
79	8148958988	127.0.0.1	W	2023-02-18 02:15:17	2023-02-21 22:17:32.996242	0	33
80	9884778378	127.0.0.1	W	2023-02-21 01:58:40	\N	1	69
79	8148958988	127.0.0.1	W	2023-02-18 02:31:51	2023-02-21 22:17:32.996242	0	34
79	8148958988	127.0.0.1	W	2023-02-18 02:33:54	2023-02-21 22:17:32.996242	0	35
79	8148958988	127.0.0.1	W	2023-02-18 02:39:43	2023-02-21 22:17:32.996242	0	36
79	8148958988	127.0.0.1	W	2023-02-18 02:42:54	2023-02-21 22:17:32.996242	0	37
79	8148958988	127.0.0.1	W	2023-02-18 02:55:48	2023-02-21 22:17:32.996242	0	38
79	8148958988	127.0.0.1	W	2023-02-18 03:00:49	2023-02-21 22:17:32.996242	0	39
79	8148958988	127.0.0.1	W	2023-02-20 19:09:00	2023-02-21 22:17:32.996242	0	40
79	8148958988	127.0.0.1	W	2023-02-20 19:52:36	2023-02-21 22:17:32.996242	0	41
79	8148958988	10.163.19.176	W	2023-02-20 20:54:54	2023-02-21 22:17:32.996242	0	42
79	8148958988	10.163.19.176	W	2023-02-20 20:55:02	2023-02-21 22:17:32.996242	0	43
79	8148958988	10.163.19.176	W	2023-02-20 20:55:21	2023-02-21 22:17:32.996242	0	44
79	8148958988	10.163.19.176	W	2023-02-20 20:55:34	2023-02-21 22:17:32.996242	0	45
79	8148958988	10.163.19.176	W	2023-02-20 20:55:50	2023-02-21 22:17:32.996242	0	46
79	8148958988	10.163.19.176	W	2023-02-20 20:56:35	2023-02-21 22:17:32.996242	0	47
79	8148958988	10.163.19.176	W	2023-02-20 20:57:05	2023-02-21 22:17:32.996242	0	48
79	8148958988	10.163.19.148	W	2023-02-21 21:54:56	2023-02-21 22:17:32.996242	0	86
79	8148958988	10.163.19.148	W	2023-02-21 22:21:12	2023-02-21 22:17:32.996242	0	88
79	8148958988	10.163.19.176	W	2023-02-20 20:57:37	2023-02-21 22:17:32.996242	0	49
79	8148958988	127.0.0.1	W	2023-02-20 20:58:21	2023-02-21 22:17:32.996242	0	50
79	8148958988	127.0.0.1	W	2023-02-20 20:58:27	2023-02-21 22:17:32.996242	0	51
79	8148958988	127.0.0.1	W	2023-02-20 20:58:32	2023-02-21 22:17:32.996242	0	52
79	8148958988	127.0.0.1	W	2023-02-20 22:31:32	2023-02-21 22:17:32.996242	0	67
79	8148958988	127.0.0.1	W	2023-02-17 23:51:19	2023-02-21 22:17:32.996242	0	18
79	8148958988	10.163.19.173	W	2023-02-18 00:02:26	2023-02-21 22:17:32.996242	0	19
79	8148958988	10.163.19.173	W	2023-02-18 00:02:39	2023-02-21 22:17:32.996242	0	20
79	8148958988	::1	W	2023-02-18 00:04:14	2023-02-21 22:17:32.996242	0	21
79	8148958988	10.163.19.176	W	2023-02-18 00:05:01	2023-02-21 22:17:32.996242	0	22
79	8148958988	10.163.19.176	W	2023-02-18 00:05:53	2023-02-21 22:17:32.996242	0	23
79	8148958988	10.163.19.176	W	2023-02-18 00:06:05	2023-02-21 22:17:32.996242	0	24
79	8148958988	127.0.0.1	W	2023-02-20 21:00:34	2023-02-21 22:17:32.996242	0	53
79	8148958988	127.0.0.1	W	2023-02-20 21:01:02	2023-02-21 22:17:32.996242	0	54
79	8148958988	127.0.0.1	W	2023-02-20 21:04:14	2023-02-21 22:17:32.996242	0	55
79	8148958988	127.0.0.1	W	2023-02-20 21:08:45	2023-02-21 22:17:32.996242	0	56
79	8148958988	10.163.19.148	W	2023-02-21 22:10:28	2023-02-21 22:17:32.996242	0	87
79	8148958988	127.0.0.1	W	2023-02-20 21:08:59	2023-02-21 22:17:32.996242	0	57
79	8148958988	10.163.19.173	W	2023-02-20 21:19:13	2023-02-21 22:17:32.996242	0	59
79	8148958988	10.163.19.176	W	2023-02-21 21:43:35	2023-02-21 22:17:32.996242	0	82
79	8148958988	127.0.0.1	W	2023-02-20 21:25:54	2023-02-21 22:17:32.996242	0	61
79	8148958988	127.0.0.1	W	2023-02-20 21:40:55	2023-02-21 22:17:32.996242	0	66
79	8148958988	10.163.19.176	W	2023-02-21 21:22:58	2023-02-21 22:17:32.996242	0	79
79	8148958988	127.0.0.1	W	2023-02-21 19:15:11	2023-02-21 22:17:32.996242	0	70
79	8148958988	127.0.0.1	W	2023-02-21 19:23:19	2023-02-21 22:17:32.996242	0	72
79	8148958988	127.0.0.1	W	2023-02-21 20:16:08	2023-02-21 22:17:32.996242	0	77
79	8148958988	10.163.19.176	W	2023-02-20 23:24:28	2023-02-21 22:17:32.996242	0	91
79	8148958988	10.163.19.176	W	2023-02-20 23:36:21	2023-02-21 22:17:32.996242	0	93
79	8148958988	10.163.19.176	W	2023-02-21 21:35:56	2023-02-21 22:17:32.996242	0	81
79	8148958988	10.163.19.176	W	2023-02-20 23:28:45	2023-02-21 22:17:32.996242	0	92
79	8148958988	10.163.19.176	W	2023-02-21 00:18:04	2023-02-21 22:17:32.996242	0	94
79	8148958988	10.163.19.176	W	2023-02-21 00:41:09	2023-02-21 22:17:32.996242	0	95
79	8148958988	10.163.19.176	W	2023-02-21 00:45:32	2023-02-21 22:17:32.996242	0	96
79	8148958988	10.163.19.176	W	2023-02-21 00:51:12	2023-02-21 22:17:32.996242	0	97
79	8148958988	10.163.19.148	W	2023-02-21 01:02:21	2023-02-21 22:17:32.996242	0	98
79	8148958988	10.163.19.148	W	2023-02-21 01:08:04	2023-02-21 22:17:32.996242	0	99
79	8148958988	10.163.19.176	W	2023-02-21 01:45:01	2023-02-21 22:17:32.996242	0	100
83	9159698082	10.163.19.176	W	2023-03-23 12:04:44	\N	1	103
83	9159698082	10.163.19.176	W	2023-03-23 12:11:57	\N	1	104
83	9159698082	10.163.2.160	W	2023-03-24 10:42:44	\N	1	105
79	8148958988	10.163.2.160	W	2023-03-24 10:49:17	\N	1	106
79	8148958988	10.163.2.160	W	2023-03-24 12:27:35	\N	1	107
79	8148958988	10.163.19.176	W	2023-03-24 12:33:21	\N	1	108
79	8148958988	10.163.19.173	W	2023-03-24 14:56:22	\N	1	117
79	8148958988	10.163.19.173	W	2023-03-27 11:06:58	\N	1	123
85	9487687827	10.163.19.176	W	2023-03-24 12:36:49	2023-03-28 14:58:46.746698	0	109
85	9487687827	10.163.2.160	W	2023-03-24 12:46:09	2023-03-28 14:58:46.746698	0	110
85	9487687827	10.163.19.176	W	2023-03-24 12:54:31	2023-03-28 14:58:46.746698	0	111
85	9487687827	10.163.19.173	W	2023-03-24 13:00:43	2023-03-28 14:58:46.746698	0	112
85	9487687827	10.163.19.173	W	2023-03-24 13:01:26	2023-03-28 14:58:46.746698	0	113
85	9487687827	10.163.19.176	W	2023-03-24 13:21:02	2023-03-28 14:58:46.746698	0	116
85	9487687827	10.163.19.173	W	2023-03-24 14:56:49	2023-03-28 14:58:46.746698	0	118
85	9487687827	10.163.19.173	W	2023-03-24 14:58:41	2023-03-28 14:58:46.746698	0	119
85	9487687827	10.163.19.176	W	2023-03-24 15:51:38	2023-03-28 14:58:46.746698	0	120
85	9487687827	10.163.2.160	W	2023-03-24 16:24:10	2023-03-28 14:58:46.746698	0	121
85	9487687827	10.163.2.160	W	2023-03-24 17:13:21	2023-03-28 14:58:46.746698	0	122
85	9487687827	10.163.19.173	W	2023-03-27 11:07:16	2023-03-28 14:58:46.746698	0	124
85	9487687827	10.163.19.176	W	2023-03-27 11:07:52	2023-03-28 14:58:46.746698	0	125
85	9487687827	10.163.19.173	W	2023-03-27 11:09:13	2023-03-28 14:58:46.746698	0	126
85	9487687827	10.163.2.250	W	2023-03-27 13:12:32	2023-03-28 14:58:46.746698	0	128
85	9487687827	10.163.19.176	W	2023-03-27 15:15:50	2023-03-28 14:58:46.746698	0	129
85	9487687827	10.163.2.250	W	2023-03-27 15:43:31	2023-03-28 14:58:46.746698	0	130
83	9159698082	10.163.19.176	W	2023-03-27 15:52:03	\N	1	131
85	9487687827	10.163.19.176	W	2023-03-27 18:00:00	2023-03-28 14:58:46.746698	0	136
85	9487687827	10.163.19.176	W	2023-03-28 10:31:12	2023-03-28 14:58:46.746698	0	137
85	9487687827	10.163.2.96	W	2023-03-28 11:20:18	2023-03-28 14:58:46.746698	0	138
85	9487687827	10.163.2.250	W	2023-03-28 11:40:29	2023-03-28 14:58:46.746698	0	139
7	9876543210	10.163.19.173	W	2023-03-24 13:14:45	2023-03-27 16:23:00.936896	0	114
7	9876543210	10.163.19.173	W	2023-03-24 13:18:31	2023-03-27 16:23:00.936896	0	115
7	9876543210	10.163.19.176	W	2023-03-27 12:44:49	2023-03-27 16:23:00.936896	0	127
7	9876543210	10.163.2.250	W	2023-03-27 16:02:00	2023-03-27 16:23:00.936896	0	132
7	9876543210	10.163.2.250	W	2023-03-27 16:22:44	2023-03-27 16:23:00.936896	0	133
1	9885632563	10.163.2.250	W	2023-03-27 16:23:21	\N	1	134
7	9876543210	10.163.2.26	W	2023-03-27 16:31:04	\N	1	135
85	9487687827	10.163.2.96	W	2023-03-28 12:22:46	2023-03-28 14:58:46.746698	0	143
87	9080076157	10.163.2.250	W	2023-03-28 11:47:20	2023-03-28 18:29:17.326132	0	140
87	9080076157	10.163.2.250	W	2023-03-28 11:49:32	2023-03-28 18:29:17.326132	0	141
87	9080076157	10.163.19.176	W	2023-03-28 12:17:07	2023-03-28 18:29:17.326132	0	142
87	9080076157	10.163.2.96	W	2023-03-28 14:58:57	2023-03-28 18:29:17.326132	0	144
87	9080076157	10.163.2.26	W	2023-03-28 15:08:03	2023-03-28 18:29:17.326132	0	145
87	9080076157	10.163.19.176	W	2023-03-28 15:41:05	2023-03-28 18:29:17.326132	0	146
87	9080076157	10.163.19.173	W	2023-03-28 16:12:14	2023-03-28 18:29:17.326132	0	147
87	9080076157	10.163.2.26	W	2023-03-28 17:04:10	2023-03-28 18:29:17.326132	0	148
87	9080076157	10.163.19.176	W	2023-03-28 18:35:10	\N	1	149
\.


--
-- TOC entry 3225 (class 0 OID 623443)
-- Dependencies: 218
-- Data for Name: mst_usertype; Type: TABLE DATA; Schema: mybillmyright; Owner: postgres
--

COPY mybillmyright.mst_usertype (usertypeid, usertypesname, usertypelname, status, createdby, createdon, updatedby, updatedon, usertypecode) FROM stdin;
1	C	Citizen	Y	\N	\N	\N	\N	01
2	D	Department	Y	\N	\N	\N	\N	02
\.


--
-- TOC entry 3227 (class 0 OID 623451)
-- Dependencies: 220
-- Data for Name: mst_zone; Type: TABLE DATA; Schema: mybillmyright; Owner: postgres
--

COPY mybillmyright.mst_zone (zoneid, zonecode, zonesname, zonelname, statecode, statusflag, createdby, createdon, updatedby, updatedon) FROM stdin;
1	01	CH	Chennai	\N	\N	\N	\N	\N	\N
2	02	Z-I	Zone-I	\N	\N	\N	\N	\N	\N
3	03	Z-II	Zone-II	\N	\N	\N	\N	\N	\N
4	04	Z-III	Zone-III	\N	\N	\N	\N	\N	\N
5	05	Z-IV	Zone-IV	\N	\N	\N	\N	\N	\N
\.


--
-- TOC entry 3202 (class 0 OID 620555)
-- Dependencies: 195
-- Data for Name: test; Type: TABLE DATA; Schema: mybillmyright; Owner: postgres
--

COPY mybillmyright.test (id, fname) FROM stdin;
1	Paul
2	Paulw
\.


--
-- TOC entry 3190 (class 0 OID 585136)
-- Dependencies: 183
-- Data for Name: test; Type: TABLE DATA; Schema: public; Owner: nursec
--

COPY public.test (id, name) FROM stdin;
\.


--
-- TOC entry 3303 (class 0 OID 0)
-- Dependencies: 185
-- Name: billdetail_billdetailid_seq; Type: SEQUENCE SET; Schema: mybillmyright; Owner: postgres
--

SELECT pg_catalog.setval('mybillmyright.billdetail_billdetailid_seq', 219, true);


--
-- TOC entry 3304 (class 0 OID 0)
-- Dependencies: 197
-- Name: mst_charge_chargeid_seq; Type: SEQUENCE SET; Schema: mybillmyright; Owner: postgres
--

SELECT pg_catalog.setval('mybillmyright.mst_charge_chargeid_seq', 5, true);


--
-- TOC entry 3305 (class 0 OID 0)
-- Dependencies: 199
-- Name: mst_circle_circleid_seq; Type: SEQUENCE SET; Schema: mybillmyright; Owner: postgres
--

SELECT pg_catalog.setval('mybillmyright.mst_circle_circleid_seq', 1, false);


--
-- TOC entry 3306 (class 0 OID 0)
-- Dependencies: 201
-- Name: mst_dept_user_userid_seq; Type: SEQUENCE SET; Schema: mybillmyright; Owner: postgres
--

SELECT pg_catalog.setval('mybillmyright.mst_dept_user_userid_seq', 2, true);


--
-- TOC entry 3307 (class 0 OID 0)
-- Dependencies: 203
-- Name: mst_division_divisionid_seq; Type: SEQUENCE SET; Schema: mybillmyright; Owner: postgres
--

SELECT pg_catalog.setval('mybillmyright.mst_division_divisionid_seq', 1, false);


--
-- TOC entry 3308 (class 0 OID 0)
-- Dependencies: 207
-- Name: mst_menu_mapping_menuid_seq; Type: SEQUENCE SET; Schema: mybillmyright; Owner: postgres
--

SELECT pg_catalog.setval('mybillmyright.mst_menu_mapping_menuid_seq', 1, false);


--
-- TOC entry 3309 (class 0 OID 0)
-- Dependencies: 205
-- Name: mst_menu_menuid_seq; Type: SEQUENCE SET; Schema: mybillmyright; Owner: postgres
--

SELECT pg_catalog.setval('mybillmyright.mst_menu_menuid_seq', 1, false);


--
-- TOC entry 3310 (class 0 OID 0)
-- Dependencies: 209
-- Name: mst_role_roleid_seq; Type: SEQUENCE SET; Schema: mybillmyright; Owner: postgres
--

SELECT pg_catalog.setval('mybillmyright.mst_role_roleid_seq', 1, false);


--
-- TOC entry 3311 (class 0 OID 0)
-- Dependencies: 211
-- Name: mst_roleaction_roleactionid_seq; Type: SEQUENCE SET; Schema: mybillmyright; Owner: postgres
--

SELECT pg_catalog.setval('mybillmyright.mst_roleaction_roleactionid_seq', 1, false);


--
-- TOC entry 3312 (class 0 OID 0)
-- Dependencies: 213
-- Name: mst_roletype_roletypeid_seq; Type: SEQUENCE SET; Schema: mybillmyright; Owner: postgres
--

SELECT pg_catalog.setval('mybillmyright.mst_roletype_roletypeid_seq', 1, false);


--
-- TOC entry 3313 (class 0 OID 0)
-- Dependencies: 215
-- Name: mst_user_charge_userchargeid_seq; Type: SEQUENCE SET; Schema: mybillmyright; Owner: postgres
--

SELECT pg_catalog.setval('mybillmyright.mst_user_charge_userchargeid_seq', 3, true);


--
-- TOC entry 3314 (class 0 OID 0)
-- Dependencies: 192
-- Name: mst_user_userid_seq; Type: SEQUENCE SET; Schema: mybillmyright; Owner: postgres
--

SELECT pg_catalog.setval('mybillmyright.mst_user_userid_seq', 87, true);


--
-- TOC entry 3315 (class 0 OID 0)
-- Dependencies: 221
-- Name: mst_userlog_userlogid_seq; Type: SEQUENCE SET; Schema: mybillmyright; Owner: postgres
--

SELECT pg_catalog.setval('mybillmyright.mst_userlog_userlogid_seq', 6, true);


--
-- TOC entry 3316 (class 0 OID 0)
-- Dependencies: 194
-- Name: mst_userlogindetail_userloginid_seq; Type: SEQUENCE SET; Schema: mybillmyright; Owner: postgres
--

SELECT pg_catalog.setval('mybillmyright.mst_userlogindetail_userloginid_seq', 149, true);


--
-- TOC entry 3317 (class 0 OID 0)
-- Dependencies: 217
-- Name: mst_usertype_usertypeid_seq; Type: SEQUENCE SET; Schema: mybillmyright; Owner: postgres
--

SELECT pg_catalog.setval('mybillmyright.mst_usertype_usertypeid_seq', 1, false);


--
-- TOC entry 3318 (class 0 OID 0)
-- Dependencies: 219
-- Name: mst_zone_zoneid_seq; Type: SEQUENCE SET; Schema: mybillmyright; Owner: postgres
--

SELECT pg_catalog.setval('mybillmyright.mst_zone_zoneid_seq', 1, false);


--
-- TOC entry 3319 (class 0 OID 0)
-- Dependencies: 196
-- Name: test_id_seq; Type: SEQUENCE SET; Schema: mybillmyright; Owner: postgres
--

SELECT pg_catalog.setval('mybillmyright.test_id_seq', 2, true);


--
-- TOC entry 3320 (class 0 OID 0)
-- Dependencies: 182
-- Name: test_id_seq; Type: SEQUENCE SET; Schema: public; Owner: nursec
--

SELECT pg_catalog.setval('public.test_id_seq', 1, false);


--
-- TOC entry 3026 (class 2606 OID 620569)
-- Name: billdetail billdetail_pk; Type: CONSTRAINT; Schema: mybillmyright; Owner: postgres
--

ALTER TABLE ONLY mybillmyright.billdetail
    ADD CONSTRAINT billdetail_pk PRIMARY KEY (billdetailid);


--
-- TOC entry 3040 (class 2606 OID 623350)
-- Name: mst_charge mst_charge_pkey; Type: CONSTRAINT; Schema: mybillmyright; Owner: postgres
--

ALTER TABLE ONLY mybillmyright.mst_charge
    ADD CONSTRAINT mst_charge_pkey PRIMARY KEY (chargeid);


--
-- TOC entry 3028 (class 2606 OID 620571)
-- Name: mst_config mst_config_pkey; Type: CONSTRAINT; Schema: mybillmyright; Owner: postgres
--

ALTER TABLE ONLY mybillmyright.mst_config
    ADD CONSTRAINT mst_config_pkey PRIMARY KEY (configcode);


--
-- TOC entry 3030 (class 2606 OID 620573)
-- Name: mst_configlog mst_configlog_pkey; Type: CONSTRAINT; Schema: mybillmyright; Owner: postgres
--

ALTER TABLE ONLY mybillmyright.mst_configlog
    ADD CONSTRAINT mst_configlog_pkey PRIMARY KEY (configlogid);


--
-- TOC entry 3044 (class 2606 OID 623373)
-- Name: mst_dept_user mst_dept_user_pkey; Type: CONSTRAINT; Schema: mybillmyright; Owner: postgres
--

ALTER TABLE ONLY mybillmyright.mst_dept_user
    ADD CONSTRAINT mst_dept_user_pkey PRIMARY KEY (mobilenumber);


--
-- TOC entry 3032 (class 2606 OID 620575)
-- Name: mst_district mst_district_pkey; Type: CONSTRAINT; Schema: mybillmyright; Owner: postgres
--

ALTER TABLE ONLY mybillmyright.mst_district
    ADD CONSTRAINT mst_district_pkey PRIMARY KEY (distcode);


--
-- TOC entry 3046 (class 2606 OID 623389)
-- Name: mst_division mst_division_pkey; Type: CONSTRAINT; Schema: mybillmyright; Owner: postgres
--

ALTER TABLE ONLY mybillmyright.mst_division
    ADD CONSTRAINT mst_division_pkey PRIMARY KEY (divisioncode);


--
-- TOC entry 3042 (class 2606 OID 623361)
-- Name: mst_circle mst_mapping_pkey; Type: CONSTRAINT; Schema: mybillmyright; Owner: postgres
--

ALTER TABLE ONLY mybillmyright.mst_circle
    ADD CONSTRAINT mst_mapping_pkey PRIMARY KEY (circleid);


--
-- TOC entry 3050 (class 2606 OID 623408)
-- Name: mst_menu_mapping mst_menu_mapping_pkey; Type: CONSTRAINT; Schema: mybillmyright; Owner: postgres
--

ALTER TABLE ONLY mybillmyright.mst_menu_mapping
    ADD CONSTRAINT mst_menu_mapping_pkey PRIMARY KEY (menuid);


--
-- TOC entry 3048 (class 2606 OID 623397)
-- Name: mst_menu mst_menu_pkey; Type: CONSTRAINT; Schema: mybillmyright; Owner: postgres
--

ALTER TABLE ONLY mybillmyright.mst_menu
    ADD CONSTRAINT mst_menu_pkey PRIMARY KEY (menuid);


--
-- TOC entry 3052 (class 2606 OID 623416)
-- Name: mst_role mst_role_pkey; Type: CONSTRAINT; Schema: mybillmyright; Owner: postgres
--

ALTER TABLE ONLY mybillmyright.mst_role
    ADD CONSTRAINT mst_role_pkey PRIMARY KEY (roleid);


--
-- TOC entry 3054 (class 2606 OID 623424)
-- Name: mst_roleaction mst_roleaction_pkey; Type: CONSTRAINT; Schema: mybillmyright; Owner: postgres
--

ALTER TABLE ONLY mybillmyright.mst_roleaction
    ADD CONSTRAINT mst_roleaction_pkey PRIMARY KEY (roleactionid);


--
-- TOC entry 3056 (class 2606 OID 623432)
-- Name: mst_roletype mst_roletype_pkey; Type: CONSTRAINT; Schema: mybillmyright; Owner: postgres
--

ALTER TABLE ONLY mybillmyright.mst_roletype
    ADD CONSTRAINT mst_roletype_pkey PRIMARY KEY (roletypeid);


--
-- TOC entry 3034 (class 2606 OID 620577)
-- Name: mst_scheme mst_scheme_pkey; Type: CONSTRAINT; Schema: mybillmyright; Owner: postgres
--

ALTER TABLE ONLY mybillmyright.mst_scheme
    ADD CONSTRAINT mst_scheme_pkey PRIMARY KEY (schemecode);


--
-- TOC entry 3036 (class 2606 OID 620579)
-- Name: mst_state mst_state_pkey; Type: CONSTRAINT; Schema: mybillmyright; Owner: postgres
--

ALTER TABLE ONLY mybillmyright.mst_state
    ADD CONSTRAINT mst_state_pkey PRIMARY KEY (statecode);


--
-- TOC entry 3058 (class 2606 OID 623440)
-- Name: mst_user_charge mst_user_charge_pkey; Type: CONSTRAINT; Schema: mybillmyright; Owner: postgres
--

ALTER TABLE ONLY mybillmyright.mst_user_charge
    ADD CONSTRAINT mst_user_charge_pkey PRIMARY KEY (userchargeid);


--
-- TOC entry 3038 (class 2606 OID 620581)
-- Name: mst_user mst_user_pkey; Type: CONSTRAINT; Schema: mybillmyright; Owner: postgres
--

ALTER TABLE ONLY mybillmyright.mst_user
    ADD CONSTRAINT mst_user_pkey PRIMARY KEY (mobilenumber);


--
-- TOC entry 3060 (class 2606 OID 623448)
-- Name: mst_usertype mst_usertype_pkey; Type: CONSTRAINT; Schema: mybillmyright; Owner: postgres
--

ALTER TABLE ONLY mybillmyright.mst_usertype
    ADD CONSTRAINT mst_usertype_pkey PRIMARY KEY (usertypecode);


--
-- TOC entry 3062 (class 2606 OID 623459)
-- Name: mst_zone mst_zone_pkey; Type: CONSTRAINT; Schema: mybillmyright; Owner: postgres
--

ALTER TABLE ONLY mybillmyright.mst_zone
    ADD CONSTRAINT mst_zone_pkey PRIMARY KEY (zonecode);


--
-- TOC entry 3024 (class 2606 OID 585141)
-- Name: test test_pkey; Type: CONSTRAINT; Schema: public; Owner: nursec
--

ALTER TABLE ONLY public.test
    ADD CONSTRAINT test_pkey PRIMARY KEY (id);


--
-- TOC entry 3063 (class 2606 OID 620582)
-- Name: billdetail billdetail_configcode_fkey; Type: FK CONSTRAINT; Schema: mybillmyright; Owner: postgres
--

ALTER TABLE ONLY mybillmyright.billdetail
    ADD CONSTRAINT billdetail_configcode_fkey FOREIGN KEY (configcode) REFERENCES mybillmyright.mst_config(configcode);


--
-- TOC entry 3064 (class 2606 OID 620587)
-- Name: billdetail billdetail_distcode_fkey; Type: FK CONSTRAINT; Schema: mybillmyright; Owner: postgres
--

ALTER TABLE ONLY mybillmyright.billdetail
    ADD CONSTRAINT billdetail_distcode_fkey FOREIGN KEY (distcode) REFERENCES mybillmyright.mst_district(distcode);


--
-- TOC entry 3065 (class 2606 OID 620592)
-- Name: billdetail billdetail_statecode_fkey; Type: FK CONSTRAINT; Schema: mybillmyright; Owner: postgres
--

ALTER TABLE ONLY mybillmyright.billdetail
    ADD CONSTRAINT billdetail_statecode_fkey FOREIGN KEY (statecode) REFERENCES mybillmyright.mst_state(statecode);


--
-- TOC entry 3066 (class 2606 OID 620597)
-- Name: mst_configlog mst_configlog_configcode_fkey; Type: FK CONSTRAINT; Schema: mybillmyright; Owner: postgres
--

ALTER TABLE ONLY mybillmyright.mst_configlog
    ADD CONSTRAINT mst_configlog_configcode_fkey FOREIGN KEY (configcode) REFERENCES mybillmyright.mst_config(configcode) NOT VALID;


--
-- TOC entry 3067 (class 2606 OID 620602)
-- Name: mst_configlog mst_configlog_schemecode_fkey; Type: FK CONSTRAINT; Schema: mybillmyright; Owner: postgres
--

ALTER TABLE ONLY mybillmyright.mst_configlog
    ADD CONSTRAINT mst_configlog_schemecode_fkey FOREIGN KEY (schemecode) REFERENCES mybillmyright.mst_scheme(schemecode) NOT VALID;


--
-- TOC entry 3068 (class 2606 OID 620607)
-- Name: mst_user mst_user_distcode_fkey; Type: FK CONSTRAINT; Schema: mybillmyright; Owner: postgres
--

ALTER TABLE ONLY mybillmyright.mst_user
    ADD CONSTRAINT mst_user_distcode_fkey FOREIGN KEY (distcode) REFERENCES mybillmyright.mst_district(distcode);


--
-- TOC entry 3069 (class 2606 OID 620612)
-- Name: mst_user mst_user_schemecode_fkey; Type: FK CONSTRAINT; Schema: mybillmyright; Owner: postgres
--

ALTER TABLE ONLY mybillmyright.mst_user
    ADD CONSTRAINT mst_user_schemecode_fkey FOREIGN KEY (schemecode) REFERENCES mybillmyright.mst_scheme(schemecode);


--
-- TOC entry 3070 (class 2606 OID 620617)
-- Name: mst_user mst_user_statecode_fkey; Type: FK CONSTRAINT; Schema: mybillmyright; Owner: postgres
--

ALTER TABLE ONLY mybillmyright.mst_user
    ADD CONSTRAINT mst_user_statecode_fkey FOREIGN KEY (statecode) REFERENCES mybillmyright.mst_state(statecode);


--
-- TOC entry 3071 (class 2606 OID 623374)
-- Name: mst_dept_user mst_user_statecode_fkey; Type: FK CONSTRAINT; Schema: mybillmyright; Owner: postgres
--

ALTER TABLE ONLY mybillmyright.mst_dept_user
    ADD CONSTRAINT mst_user_statecode_fkey FOREIGN KEY (statecode) REFERENCES mybillmyright.mst_state(statecode);


--
-- TOC entry 3072 (class 2606 OID 623473)
-- Name: mst_userlog mst_userlog_distcode_fkey; Type: FK CONSTRAINT; Schema: mybillmyright; Owner: postgres
--

ALTER TABLE ONLY mybillmyright.mst_userlog
    ADD CONSTRAINT mst_userlog_distcode_fkey FOREIGN KEY (distcode) REFERENCES mybillmyright.mst_district(distcode);


--
-- TOC entry 3073 (class 2606 OID 623478)
-- Name: mst_userlog mst_userlog_schemecode_fkey; Type: FK CONSTRAINT; Schema: mybillmyright; Owner: postgres
--

ALTER TABLE ONLY mybillmyright.mst_userlog
    ADD CONSTRAINT mst_userlog_schemecode_fkey FOREIGN KEY (schemecode) REFERENCES mybillmyright.mst_scheme(schemecode);


--
-- TOC entry 3074 (class 2606 OID 623483)
-- Name: mst_userlog mst_userlog_statecode_fkey; Type: FK CONSTRAINT; Schema: mybillmyright; Owner: postgres
--

ALTER TABLE ONLY mybillmyright.mst_userlog
    ADD CONSTRAINT mst_userlog_statecode_fkey FOREIGN KEY (statecode) REFERENCES mybillmyright.mst_state(statecode);


--
-- TOC entry 3235 (class 0 OID 0)
-- Dependencies: 8
-- Name: SCHEMA mybillmyright; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA mybillmyright FROM PUBLIC;
REVOKE ALL ON SCHEMA mybillmyright FROM postgres;
GRANT ALL ON SCHEMA mybillmyright TO postgres;
GRANT ALL ON SCHEMA mybillmyright TO nursec;


--
-- TOC entry 3236 (class 0 OID 0)
-- Dependencies: 7
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: nursec
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM nursec;
GRANT ALL ON SCHEMA public TO nursec;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- TOC entry 3237 (class 0 OID 0)
-- Dependencies: 241
-- Name: FUNCTION fn_assigningcharge_jsondata(_roletypecode character varying, _divisioncode character varying, _zonecode character varying, _distcode character varying, _circleid integer, _session_userid integer); Type: ACL; Schema: mybillmyright; Owner: postgres
--

REVOKE ALL ON FUNCTION mybillmyright.fn_assigningcharge_jsondata(_roletypecode character varying, _divisioncode character varying, _zonecode character varying, _distcode character varying, _circleid integer, _session_userid integer) FROM PUBLIC;
REVOKE ALL ON FUNCTION mybillmyright.fn_assigningcharge_jsondata(_roletypecode character varying, _divisioncode character varying, _zonecode character varying, _distcode character varying, _circleid integer, _session_userid integer) FROM postgres;
GRANT ALL ON FUNCTION mybillmyright.fn_assigningcharge_jsondata(_roletypecode character varying, _divisioncode character varying, _zonecode character varying, _distcode character varying, _circleid integer, _session_userid integer) TO postgres;
GRANT ALL ON FUNCTION mybillmyright.fn_assigningcharge_jsondata(_roletypecode character varying, _divisioncode character varying, _zonecode character varying, _distcode character varying, _circleid integer, _session_userid integer) TO PUBLIC;
GRANT ALL ON FUNCTION mybillmyright.fn_assigningcharge_jsondata(_roletypecode character varying, _divisioncode character varying, _zonecode character varying, _distcode character varying, _circleid integer, _session_userid integer) TO nursec;


--
-- TOC entry 3238 (class 0 OID 0)
-- Dependencies: 236
-- Name: FUNCTION fn_chargedetails_jsondata(_roletypecode character varying, _divisioncode character varying, _zonecode character varying, _circleid integer, _distcode character varying, _session_chargeid integer); Type: ACL; Schema: mybillmyright; Owner: postgres
--

REVOKE ALL ON FUNCTION mybillmyright.fn_chargedetails_jsondata(_roletypecode character varying, _divisioncode character varying, _zonecode character varying, _circleid integer, _distcode character varying, _session_chargeid integer) FROM PUBLIC;
REVOKE ALL ON FUNCTION mybillmyright.fn_chargedetails_jsondata(_roletypecode character varying, _divisioncode character varying, _zonecode character varying, _circleid integer, _distcode character varying, _session_chargeid integer) FROM postgres;
GRANT ALL ON FUNCTION mybillmyright.fn_chargedetails_jsondata(_roletypecode character varying, _divisioncode character varying, _zonecode character varying, _circleid integer, _distcode character varying, _session_chargeid integer) TO postgres;
GRANT ALL ON FUNCTION mybillmyright.fn_chargedetails_jsondata(_roletypecode character varying, _divisioncode character varying, _zonecode character varying, _circleid integer, _distcode character varying, _session_chargeid integer) TO PUBLIC;
GRANT ALL ON FUNCTION mybillmyright.fn_chargedetails_jsondata(_roletypecode character varying, _divisioncode character varying, _zonecode character varying, _circleid integer, _distcode character varying, _session_chargeid integer) TO nursec;


--
-- TOC entry 3239 (class 0 OID 0)
-- Dependencies: 242
-- Name: FUNCTION fn_deptuserdetails_jsondata(_roletypecode character varying, _divisioncode character varying, _zonecode character varying, _circleid integer, _distcode character varying, _session_userid integer); Type: ACL; Schema: mybillmyright; Owner: postgres
--

REVOKE ALL ON FUNCTION mybillmyright.fn_deptuserdetails_jsondata(_roletypecode character varying, _divisioncode character varying, _zonecode character varying, _circleid integer, _distcode character varying, _session_userid integer) FROM PUBLIC;
REVOKE ALL ON FUNCTION mybillmyright.fn_deptuserdetails_jsondata(_roletypecode character varying, _divisioncode character varying, _zonecode character varying, _circleid integer, _distcode character varying, _session_userid integer) FROM postgres;
GRANT ALL ON FUNCTION mybillmyright.fn_deptuserdetails_jsondata(_roletypecode character varying, _divisioncode character varying, _zonecode character varying, _circleid integer, _distcode character varying, _session_userid integer) TO postgres;
GRANT ALL ON FUNCTION mybillmyright.fn_deptuserdetails_jsondata(_roletypecode character varying, _divisioncode character varying, _zonecode character varying, _circleid integer, _distcode character varying, _session_userid integer) TO PUBLIC;
GRANT ALL ON FUNCTION mybillmyright.fn_deptuserdetails_jsondata(_roletypecode character varying, _divisioncode character varying, _zonecode character varying, _circleid integer, _distcode character varying, _session_userid integer) TO nursec;


--
-- TOC entry 3240 (class 0 OID 0)
-- Dependencies: 237
-- Name: FUNCTION fn_get_role_menu_det_jsondata(_roleid integer, _menu character varying); Type: ACL; Schema: mybillmyright; Owner: postgres
--

REVOKE ALL ON FUNCTION mybillmyright.fn_get_role_menu_det_jsondata(_roleid integer, _menu character varying) FROM PUBLIC;
REVOKE ALL ON FUNCTION mybillmyright.fn_get_role_menu_det_jsondata(_roleid integer, _menu character varying) FROM postgres;
GRANT ALL ON FUNCTION mybillmyright.fn_get_role_menu_det_jsondata(_roleid integer, _menu character varying) TO postgres;
GRANT ALL ON FUNCTION mybillmyright.fn_get_role_menu_det_jsondata(_roleid integer, _menu character varying) TO PUBLIC;
GRANT ALL ON FUNCTION mybillmyright.fn_get_role_menu_det_jsondata(_roleid integer, _menu character varying) TO nursec;


--
-- TOC entry 3241 (class 0 OID 0)
-- Dependencies: 238
-- Name: FUNCTION fn_get_rolepermission(_charge_id integer); Type: ACL; Schema: mybillmyright; Owner: postgres
--

REVOKE ALL ON FUNCTION mybillmyright.fn_get_rolepermission(_charge_id integer) FROM PUBLIC;
REVOKE ALL ON FUNCTION mybillmyright.fn_get_rolepermission(_charge_id integer) FROM postgres;
GRANT ALL ON FUNCTION mybillmyright.fn_get_rolepermission(_charge_id integer) TO postgres;
GRANT ALL ON FUNCTION mybillmyright.fn_get_rolepermission(_charge_id integer) TO PUBLIC;
GRANT ALL ON FUNCTION mybillmyright.fn_get_rolepermission(_charge_id integer) TO nursec;


--
-- TOC entry 3242 (class 0 OID 0)
-- Dependencies: 239
-- Name: FUNCTION fn_getcharge_basedon_roleid(_roleid integer, _divisioncode character varying, _zonecode character varying, _circleid integer, _distcode character varying); Type: ACL; Schema: mybillmyright; Owner: postgres
--

REVOKE ALL ON FUNCTION mybillmyright.fn_getcharge_basedon_roleid(_roleid integer, _divisioncode character varying, _zonecode character varying, _circleid integer, _distcode character varying) FROM PUBLIC;
REVOKE ALL ON FUNCTION mybillmyright.fn_getcharge_basedon_roleid(_roleid integer, _divisioncode character varying, _zonecode character varying, _circleid integer, _distcode character varying) FROM postgres;
GRANT ALL ON FUNCTION mybillmyright.fn_getcharge_basedon_roleid(_roleid integer, _divisioncode character varying, _zonecode character varying, _circleid integer, _distcode character varying) TO postgres;
GRANT ALL ON FUNCTION mybillmyright.fn_getcharge_basedon_roleid(_roleid integer, _divisioncode character varying, _zonecode character varying, _circleid integer, _distcode character varying) TO PUBLIC;
GRANT ALL ON FUNCTION mybillmyright.fn_getcharge_basedon_roleid(_roleid integer, _divisioncode character varying, _zonecode character varying, _circleid integer, _distcode character varying) TO nursec;


--
-- TOC entry 3243 (class 0 OID 0)
-- Dependencies: 240
-- Name: FUNCTION fn_getcharge_basedon_roleid(_roletypecode character varying, _divisioncode character varying, _zonecode character varying, _circleid integer, _distcode character varying); Type: ACL; Schema: mybillmyright; Owner: postgres
--

REVOKE ALL ON FUNCTION mybillmyright.fn_getcharge_basedon_roleid(_roletypecode character varying, _divisioncode character varying, _zonecode character varying, _circleid integer, _distcode character varying) FROM PUBLIC;
REVOKE ALL ON FUNCTION mybillmyright.fn_getcharge_basedon_roleid(_roletypecode character varying, _divisioncode character varying, _zonecode character varying, _circleid integer, _distcode character varying) FROM postgres;
GRANT ALL ON FUNCTION mybillmyright.fn_getcharge_basedon_roleid(_roletypecode character varying, _divisioncode character varying, _zonecode character varying, _circleid integer, _distcode character varying) TO postgres;
GRANT ALL ON FUNCTION mybillmyright.fn_getcharge_basedon_roleid(_roletypecode character varying, _divisioncode character varying, _zonecode character varying, _circleid integer, _distcode character varying) TO PUBLIC;
GRANT ALL ON FUNCTION mybillmyright.fn_getcharge_basedon_roleid(_roletypecode character varying, _divisioncode character varying, _zonecode character varying, _circleid integer, _distcode character varying) TO nursec;


--
-- TOC entry 3244 (class 0 OID 0)
-- Dependencies: 243
-- Name: FUNCTION getawknumber(distcode character varying); Type: ACL; Schema: mybillmyright; Owner: nursec
--

REVOKE ALL ON FUNCTION mybillmyright.getawknumber(distcode character varying) FROM PUBLIC;
REVOKE ALL ON FUNCTION mybillmyright.getawknumber(distcode character varying) FROM nursec;
GRANT ALL ON FUNCTION mybillmyright.getawknumber(distcode character varying) TO nursec;
GRANT ALL ON FUNCTION mybillmyright.getawknumber(distcode character varying) TO PUBLIC;


--
-- TOC entry 3245 (class 0 OID 0)
-- Dependencies: 223
-- Name: FUNCTION invoice_count_values(); Type: ACL; Schema: mybillmyright; Owner: nursec
--

REVOKE ALL ON FUNCTION mybillmyright.invoice_count_values() FROM PUBLIC;
REVOKE ALL ON FUNCTION mybillmyright.invoice_count_values() FROM nursec;
GRANT ALL ON FUNCTION mybillmyright.invoice_count_values() TO nursec;
GRANT ALL ON FUNCTION mybillmyright.invoice_count_values() TO PUBLIC;


--
-- TOC entry 3246 (class 0 OID 0)
-- Dependencies: 184
-- Name: TABLE billdetail; Type: ACL; Schema: mybillmyright; Owner: postgres
--

REVOKE ALL ON TABLE mybillmyright.billdetail FROM PUBLIC;
REVOKE ALL ON TABLE mybillmyright.billdetail FROM postgres;
GRANT ALL ON TABLE mybillmyright.billdetail TO postgres;
GRANT ALL ON TABLE mybillmyright.billdetail TO nursec;


--
-- TOC entry 3248 (class 0 OID 0)
-- Dependencies: 185
-- Name: SEQUENCE billdetail_billdetailid_seq; Type: ACL; Schema: mybillmyright; Owner: postgres
--

REVOKE ALL ON SEQUENCE mybillmyright.billdetail_billdetailid_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE mybillmyright.billdetail_billdetailid_seq FROM postgres;
GRANT ALL ON SEQUENCE mybillmyright.billdetail_billdetailid_seq TO postgres;
GRANT ALL ON SEQUENCE mybillmyright.billdetail_billdetailid_seq TO nursec;


--
-- TOC entry 3249 (class 0 OID 0)
-- Dependencies: 198
-- Name: TABLE mst_charge; Type: ACL; Schema: mybillmyright; Owner: postgres
--

REVOKE ALL ON TABLE mybillmyright.mst_charge FROM PUBLIC;
REVOKE ALL ON TABLE mybillmyright.mst_charge FROM postgres;
GRANT ALL ON TABLE mybillmyright.mst_charge TO postgres;
GRANT ALL ON TABLE mybillmyright.mst_charge TO nursec;


--
-- TOC entry 3251 (class 0 OID 0)
-- Dependencies: 197
-- Name: SEQUENCE mst_charge_chargeid_seq; Type: ACL; Schema: mybillmyright; Owner: postgres
--

REVOKE ALL ON SEQUENCE mybillmyright.mst_charge_chargeid_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE mybillmyright.mst_charge_chargeid_seq FROM postgres;
GRANT ALL ON SEQUENCE mybillmyright.mst_charge_chargeid_seq TO postgres;
GRANT ALL ON SEQUENCE mybillmyright.mst_charge_chargeid_seq TO nursec;


--
-- TOC entry 3252 (class 0 OID 0)
-- Dependencies: 200
-- Name: TABLE mst_circle; Type: ACL; Schema: mybillmyright; Owner: postgres
--

REVOKE ALL ON TABLE mybillmyright.mst_circle FROM PUBLIC;
REVOKE ALL ON TABLE mybillmyright.mst_circle FROM postgres;
GRANT ALL ON TABLE mybillmyright.mst_circle TO postgres;
GRANT ALL ON TABLE mybillmyright.mst_circle TO nursec;


--
-- TOC entry 3254 (class 0 OID 0)
-- Dependencies: 199
-- Name: SEQUENCE mst_circle_circleid_seq; Type: ACL; Schema: mybillmyright; Owner: postgres
--

REVOKE ALL ON SEQUENCE mybillmyright.mst_circle_circleid_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE mybillmyright.mst_circle_circleid_seq FROM postgres;
GRANT ALL ON SEQUENCE mybillmyright.mst_circle_circleid_seq TO postgres;
GRANT ALL ON SEQUENCE mybillmyright.mst_circle_circleid_seq TO nursec;


--
-- TOC entry 3255 (class 0 OID 0)
-- Dependencies: 186
-- Name: TABLE mst_config; Type: ACL; Schema: mybillmyright; Owner: postgres
--

REVOKE ALL ON TABLE mybillmyright.mst_config FROM PUBLIC;
REVOKE ALL ON TABLE mybillmyright.mst_config FROM postgres;
GRANT ALL ON TABLE mybillmyright.mst_config TO postgres;
GRANT ALL ON TABLE mybillmyright.mst_config TO nursec;


--
-- TOC entry 3256 (class 0 OID 0)
-- Dependencies: 187
-- Name: TABLE mst_configlog; Type: ACL; Schema: mybillmyright; Owner: postgres
--

REVOKE ALL ON TABLE mybillmyright.mst_configlog FROM PUBLIC;
REVOKE ALL ON TABLE mybillmyright.mst_configlog FROM postgres;
GRANT ALL ON TABLE mybillmyright.mst_configlog TO postgres;
GRANT ALL ON TABLE mybillmyright.mst_configlog TO nursec;


--
-- TOC entry 3257 (class 0 OID 0)
-- Dependencies: 202
-- Name: TABLE mst_dept_user; Type: ACL; Schema: mybillmyright; Owner: postgres
--

REVOKE ALL ON TABLE mybillmyright.mst_dept_user FROM PUBLIC;
REVOKE ALL ON TABLE mybillmyright.mst_dept_user FROM postgres;
GRANT ALL ON TABLE mybillmyright.mst_dept_user TO postgres;
GRANT ALL ON TABLE mybillmyright.mst_dept_user TO nursec;


--
-- TOC entry 3259 (class 0 OID 0)
-- Dependencies: 201
-- Name: SEQUENCE mst_dept_user_userid_seq; Type: ACL; Schema: mybillmyright; Owner: postgres
--

REVOKE ALL ON SEQUENCE mybillmyright.mst_dept_user_userid_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE mybillmyright.mst_dept_user_userid_seq FROM postgres;
GRANT ALL ON SEQUENCE mybillmyright.mst_dept_user_userid_seq TO postgres;
GRANT ALL ON SEQUENCE mybillmyright.mst_dept_user_userid_seq TO nursec;


--
-- TOC entry 3260 (class 0 OID 0)
-- Dependencies: 188
-- Name: TABLE mst_district; Type: ACL; Schema: mybillmyright; Owner: postgres
--

REVOKE ALL ON TABLE mybillmyright.mst_district FROM PUBLIC;
REVOKE ALL ON TABLE mybillmyright.mst_district FROM postgres;
GRANT ALL ON TABLE mybillmyright.mst_district TO postgres;
GRANT ALL ON TABLE mybillmyright.mst_district TO nursec;


--
-- TOC entry 3261 (class 0 OID 0)
-- Dependencies: 204
-- Name: TABLE mst_division; Type: ACL; Schema: mybillmyright; Owner: postgres
--

REVOKE ALL ON TABLE mybillmyright.mst_division FROM PUBLIC;
REVOKE ALL ON TABLE mybillmyright.mst_division FROM postgres;
GRANT ALL ON TABLE mybillmyright.mst_division TO postgres;
GRANT ALL ON TABLE mybillmyright.mst_division TO nursec;


--
-- TOC entry 3263 (class 0 OID 0)
-- Dependencies: 203
-- Name: SEQUENCE mst_division_divisionid_seq; Type: ACL; Schema: mybillmyright; Owner: postgres
--

REVOKE ALL ON SEQUENCE mybillmyright.mst_division_divisionid_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE mybillmyright.mst_division_divisionid_seq FROM postgres;
GRANT ALL ON SEQUENCE mybillmyright.mst_division_divisionid_seq TO postgres;
GRANT ALL ON SEQUENCE mybillmyright.mst_division_divisionid_seq TO nursec;


--
-- TOC entry 3264 (class 0 OID 0)
-- Dependencies: 206
-- Name: TABLE mst_menu; Type: ACL; Schema: mybillmyright; Owner: postgres
--

REVOKE ALL ON TABLE mybillmyright.mst_menu FROM PUBLIC;
REVOKE ALL ON TABLE mybillmyright.mst_menu FROM postgres;
GRANT ALL ON TABLE mybillmyright.mst_menu TO postgres;
GRANT ALL ON TABLE mybillmyright.mst_menu TO nursec;


--
-- TOC entry 3265 (class 0 OID 0)
-- Dependencies: 208
-- Name: TABLE mst_menu_mapping; Type: ACL; Schema: mybillmyright; Owner: postgres
--

REVOKE ALL ON TABLE mybillmyright.mst_menu_mapping FROM PUBLIC;
REVOKE ALL ON TABLE mybillmyright.mst_menu_mapping FROM postgres;
GRANT ALL ON TABLE mybillmyright.mst_menu_mapping TO postgres;
GRANT ALL ON TABLE mybillmyright.mst_menu_mapping TO nursec;


--
-- TOC entry 3267 (class 0 OID 0)
-- Dependencies: 207
-- Name: SEQUENCE mst_menu_mapping_menuid_seq; Type: ACL; Schema: mybillmyright; Owner: postgres
--

REVOKE ALL ON SEQUENCE mybillmyright.mst_menu_mapping_menuid_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE mybillmyright.mst_menu_mapping_menuid_seq FROM postgres;
GRANT ALL ON SEQUENCE mybillmyright.mst_menu_mapping_menuid_seq TO postgres;
GRANT ALL ON SEQUENCE mybillmyright.mst_menu_mapping_menuid_seq TO nursec;


--
-- TOC entry 3269 (class 0 OID 0)
-- Dependencies: 205
-- Name: SEQUENCE mst_menu_menuid_seq; Type: ACL; Schema: mybillmyright; Owner: postgres
--

REVOKE ALL ON SEQUENCE mybillmyright.mst_menu_menuid_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE mybillmyright.mst_menu_menuid_seq FROM postgres;
GRANT ALL ON SEQUENCE mybillmyright.mst_menu_menuid_seq TO postgres;
GRANT ALL ON SEQUENCE mybillmyright.mst_menu_menuid_seq TO nursec;


--
-- TOC entry 3270 (class 0 OID 0)
-- Dependencies: 210
-- Name: TABLE mst_role; Type: ACL; Schema: mybillmyright; Owner: postgres
--

REVOKE ALL ON TABLE mybillmyright.mst_role FROM PUBLIC;
REVOKE ALL ON TABLE mybillmyright.mst_role FROM postgres;
GRANT ALL ON TABLE mybillmyright.mst_role TO postgres;
GRANT ALL ON TABLE mybillmyright.mst_role TO nursec;


--
-- TOC entry 3272 (class 0 OID 0)
-- Dependencies: 209
-- Name: SEQUENCE mst_role_roleid_seq; Type: ACL; Schema: mybillmyright; Owner: postgres
--

REVOKE ALL ON SEQUENCE mybillmyright.mst_role_roleid_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE mybillmyright.mst_role_roleid_seq FROM postgres;
GRANT ALL ON SEQUENCE mybillmyright.mst_role_roleid_seq TO postgres;
GRANT ALL ON SEQUENCE mybillmyright.mst_role_roleid_seq TO nursec;


--
-- TOC entry 3273 (class 0 OID 0)
-- Dependencies: 212
-- Name: TABLE mst_roleaction; Type: ACL; Schema: mybillmyright; Owner: postgres
--

REVOKE ALL ON TABLE mybillmyright.mst_roleaction FROM PUBLIC;
REVOKE ALL ON TABLE mybillmyright.mst_roleaction FROM postgres;
GRANT ALL ON TABLE mybillmyright.mst_roleaction TO postgres;
GRANT ALL ON TABLE mybillmyright.mst_roleaction TO nursec;


--
-- TOC entry 3275 (class 0 OID 0)
-- Dependencies: 211
-- Name: SEQUENCE mst_roleaction_roleactionid_seq; Type: ACL; Schema: mybillmyright; Owner: postgres
--

REVOKE ALL ON SEQUENCE mybillmyright.mst_roleaction_roleactionid_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE mybillmyright.mst_roleaction_roleactionid_seq FROM postgres;
GRANT ALL ON SEQUENCE mybillmyright.mst_roleaction_roleactionid_seq TO postgres;
GRANT ALL ON SEQUENCE mybillmyright.mst_roleaction_roleactionid_seq TO nursec;


--
-- TOC entry 3276 (class 0 OID 0)
-- Dependencies: 214
-- Name: TABLE mst_roletype; Type: ACL; Schema: mybillmyright; Owner: postgres
--

REVOKE ALL ON TABLE mybillmyright.mst_roletype FROM PUBLIC;
REVOKE ALL ON TABLE mybillmyright.mst_roletype FROM postgres;
GRANT ALL ON TABLE mybillmyright.mst_roletype TO postgres;
GRANT ALL ON TABLE mybillmyright.mst_roletype TO nursec;


--
-- TOC entry 3278 (class 0 OID 0)
-- Dependencies: 213
-- Name: SEQUENCE mst_roletype_roletypeid_seq; Type: ACL; Schema: mybillmyright; Owner: postgres
--

REVOKE ALL ON SEQUENCE mybillmyright.mst_roletype_roletypeid_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE mybillmyright.mst_roletype_roletypeid_seq FROM postgres;
GRANT ALL ON SEQUENCE mybillmyright.mst_roletype_roletypeid_seq TO postgres;
GRANT ALL ON SEQUENCE mybillmyright.mst_roletype_roletypeid_seq TO nursec;


--
-- TOC entry 3279 (class 0 OID 0)
-- Dependencies: 189
-- Name: TABLE mst_scheme; Type: ACL; Schema: mybillmyright; Owner: postgres
--

REVOKE ALL ON TABLE mybillmyright.mst_scheme FROM PUBLIC;
REVOKE ALL ON TABLE mybillmyright.mst_scheme FROM postgres;
GRANT ALL ON TABLE mybillmyright.mst_scheme TO postgres;
GRANT ALL ON TABLE mybillmyright.mst_scheme TO nursec;


--
-- TOC entry 3280 (class 0 OID 0)
-- Dependencies: 190
-- Name: TABLE mst_state; Type: ACL; Schema: mybillmyright; Owner: postgres
--

REVOKE ALL ON TABLE mybillmyright.mst_state FROM PUBLIC;
REVOKE ALL ON TABLE mybillmyright.mst_state FROM postgres;
GRANT ALL ON TABLE mybillmyright.mst_state TO postgres;
GRANT ALL ON TABLE mybillmyright.mst_state TO nursec;


--
-- TOC entry 3281 (class 0 OID 0)
-- Dependencies: 191
-- Name: TABLE mst_user; Type: ACL; Schema: mybillmyright; Owner: postgres
--

REVOKE ALL ON TABLE mybillmyright.mst_user FROM PUBLIC;
REVOKE ALL ON TABLE mybillmyright.mst_user FROM postgres;
GRANT ALL ON TABLE mybillmyright.mst_user TO postgres;
GRANT ALL ON TABLE mybillmyright.mst_user TO nursec;


--
-- TOC entry 3282 (class 0 OID 0)
-- Dependencies: 216
-- Name: TABLE mst_user_charge; Type: ACL; Schema: mybillmyright; Owner: postgres
--

REVOKE ALL ON TABLE mybillmyright.mst_user_charge FROM PUBLIC;
REVOKE ALL ON TABLE mybillmyright.mst_user_charge FROM postgres;
GRANT ALL ON TABLE mybillmyright.mst_user_charge TO postgres;
GRANT ALL ON TABLE mybillmyright.mst_user_charge TO nursec;


--
-- TOC entry 3284 (class 0 OID 0)
-- Dependencies: 215
-- Name: SEQUENCE mst_user_charge_userchargeid_seq; Type: ACL; Schema: mybillmyright; Owner: postgres
--

REVOKE ALL ON SEQUENCE mybillmyright.mst_user_charge_userchargeid_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE mybillmyright.mst_user_charge_userchargeid_seq FROM postgres;
GRANT ALL ON SEQUENCE mybillmyright.mst_user_charge_userchargeid_seq TO postgres;
GRANT ALL ON SEQUENCE mybillmyright.mst_user_charge_userchargeid_seq TO nursec;


--
-- TOC entry 3286 (class 0 OID 0)
-- Dependencies: 192
-- Name: SEQUENCE mst_user_userid_seq; Type: ACL; Schema: mybillmyright; Owner: postgres
--

REVOKE ALL ON SEQUENCE mybillmyright.mst_user_userid_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE mybillmyright.mst_user_userid_seq FROM postgres;
GRANT ALL ON SEQUENCE mybillmyright.mst_user_userid_seq TO postgres;
GRANT ALL ON SEQUENCE mybillmyright.mst_user_userid_seq TO nursec;


--
-- TOC entry 3287 (class 0 OID 0)
-- Dependencies: 222
-- Name: TABLE mst_userlog; Type: ACL; Schema: mybillmyright; Owner: postgres
--

REVOKE ALL ON TABLE mybillmyright.mst_userlog FROM PUBLIC;
REVOKE ALL ON TABLE mybillmyright.mst_userlog FROM postgres;
GRANT ALL ON TABLE mybillmyright.mst_userlog TO postgres;
GRANT ALL ON TABLE mybillmyright.mst_userlog TO nursec;


--
-- TOC entry 3289 (class 0 OID 0)
-- Dependencies: 221
-- Name: SEQUENCE mst_userlog_userlogid_seq; Type: ACL; Schema: mybillmyright; Owner: postgres
--

REVOKE ALL ON SEQUENCE mybillmyright.mst_userlog_userlogid_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE mybillmyright.mst_userlog_userlogid_seq FROM postgres;
GRANT ALL ON SEQUENCE mybillmyright.mst_userlog_userlogid_seq TO postgres;
GRANT ALL ON SEQUENCE mybillmyright.mst_userlog_userlogid_seq TO nursec;


--
-- TOC entry 3290 (class 0 OID 0)
-- Dependencies: 193
-- Name: TABLE mst_userlogindetail; Type: ACL; Schema: mybillmyright; Owner: postgres
--

REVOKE ALL ON TABLE mybillmyright.mst_userlogindetail FROM PUBLIC;
REVOKE ALL ON TABLE mybillmyright.mst_userlogindetail FROM postgres;
GRANT ALL ON TABLE mybillmyright.mst_userlogindetail TO postgres;
GRANT ALL ON TABLE mybillmyright.mst_userlogindetail TO nursec;


--
-- TOC entry 3292 (class 0 OID 0)
-- Dependencies: 194
-- Name: SEQUENCE mst_userlogindetail_userloginid_seq; Type: ACL; Schema: mybillmyright; Owner: postgres
--

REVOKE ALL ON SEQUENCE mybillmyright.mst_userlogindetail_userloginid_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE mybillmyright.mst_userlogindetail_userloginid_seq FROM postgres;
GRANT ALL ON SEQUENCE mybillmyright.mst_userlogindetail_userloginid_seq TO postgres;
GRANT ALL ON SEQUENCE mybillmyright.mst_userlogindetail_userloginid_seq TO nursec;


--
-- TOC entry 3293 (class 0 OID 0)
-- Dependencies: 218
-- Name: TABLE mst_usertype; Type: ACL; Schema: mybillmyright; Owner: postgres
--

REVOKE ALL ON TABLE mybillmyright.mst_usertype FROM PUBLIC;
REVOKE ALL ON TABLE mybillmyright.mst_usertype FROM postgres;
GRANT ALL ON TABLE mybillmyright.mst_usertype TO postgres;
GRANT ALL ON TABLE mybillmyright.mst_usertype TO nursec;


--
-- TOC entry 3295 (class 0 OID 0)
-- Dependencies: 217
-- Name: SEQUENCE mst_usertype_usertypeid_seq; Type: ACL; Schema: mybillmyright; Owner: postgres
--

REVOKE ALL ON SEQUENCE mybillmyright.mst_usertype_usertypeid_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE mybillmyright.mst_usertype_usertypeid_seq FROM postgres;
GRANT ALL ON SEQUENCE mybillmyright.mst_usertype_usertypeid_seq TO postgres;
GRANT ALL ON SEQUENCE mybillmyright.mst_usertype_usertypeid_seq TO nursec;


--
-- TOC entry 3296 (class 0 OID 0)
-- Dependencies: 220
-- Name: TABLE mst_zone; Type: ACL; Schema: mybillmyright; Owner: postgres
--

REVOKE ALL ON TABLE mybillmyright.mst_zone FROM PUBLIC;
REVOKE ALL ON TABLE mybillmyright.mst_zone FROM postgres;
GRANT ALL ON TABLE mybillmyright.mst_zone TO postgres;
GRANT ALL ON TABLE mybillmyright.mst_zone TO nursec;


--
-- TOC entry 3298 (class 0 OID 0)
-- Dependencies: 219
-- Name: SEQUENCE mst_zone_zoneid_seq; Type: ACL; Schema: mybillmyright; Owner: postgres
--

REVOKE ALL ON SEQUENCE mybillmyright.mst_zone_zoneid_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE mybillmyright.mst_zone_zoneid_seq FROM postgres;
GRANT ALL ON SEQUENCE mybillmyright.mst_zone_zoneid_seq TO postgres;
GRANT ALL ON SEQUENCE mybillmyright.mst_zone_zoneid_seq TO nursec;


--
-- TOC entry 3299 (class 0 OID 0)
-- Dependencies: 195
-- Name: TABLE test; Type: ACL; Schema: mybillmyright; Owner: postgres
--

REVOKE ALL ON TABLE mybillmyright.test FROM PUBLIC;
REVOKE ALL ON TABLE mybillmyright.test FROM postgres;
GRANT ALL ON TABLE mybillmyright.test TO postgres;
GRANT ALL ON TABLE mybillmyright.test TO nursec;


--
-- TOC entry 3301 (class 0 OID 0)
-- Dependencies: 196
-- Name: SEQUENCE test_id_seq; Type: ACL; Schema: mybillmyright; Owner: postgres
--

REVOKE ALL ON SEQUENCE mybillmyright.test_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE mybillmyright.test_id_seq FROM postgres;
GRANT ALL ON SEQUENCE mybillmyright.test_id_seq TO postgres;
GRANT ALL ON SEQUENCE mybillmyright.test_id_seq TO nursec;


--
-- TOC entry 1774 (class 826 OID 622103)
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: mybillmyright; Owner: nursec
--

ALTER DEFAULT PRIVILEGES FOR ROLE nursec IN SCHEMA mybillmyright REVOKE ALL ON TABLES  FROM PUBLIC;


--
-- TOC entry 1773 (class 826 OID 585231)
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: -; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres REVOKE ALL ON TABLES  FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres REVOKE ALL ON TABLES  FROM postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres GRANT ALL ON TABLES  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres GRANT ALL ON TABLES  TO nursec;


-- Completed on 2023-03-31 15:40:29

--
-- PostgreSQL database dump complete
--

