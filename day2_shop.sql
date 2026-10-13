--
-- PostgreSQL database dump
--

\restrict wWC53GesWT3QYAKuHE43NgR2eXJdNdR1QT5iIkJCmWxrVbpLSHjHhVujZGvtccx

-- Dumped from database version 15.19 (Homebrew)
-- Dumped by pg_dump version 15.19 (Homebrew)

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: products; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.products (
    id integer NOT NULL,
    name text NOT NULL,
    price numeric(10,2) NOT NULL,
    in_stock boolean DEFAULT true NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT products_price_check CHECK ((price > (0)::numeric))
);


--
-- Name: products_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.products_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.products_id_seq OWNED BY public.products.id;


--
-- Name: products id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products ALTER COLUMN id SET DEFAULT nextval('public.products_id_seq'::regclass);


--
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.products (id, name, price, in_stock, created_at) FROM stdin;
1	Ноутбук	75000.00	t	2026-10-13 18:45:28.367904
2	Мышь	1200.50	t	2026-10-13 18:45:28.367904
3	Клавиатура	3500.00	f	2026-10-13 18:45:28.367904
4	Монитор	18900.99	t	2026-10-13 18:45:28.367904
5	Наушники	4200.00	f	2026-10-13 18:45:28.367904
6	lunacy	7000.00	t	2026-10-13 18:47:27.621403
8	test	100.00	t	2026-10-13 18:49:16.840505
\.


--
-- Name: products_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.products_id_seq', 8, true);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- PostgreSQL database dump complete
--

\unrestrict wWC53GesWT3QYAKuHE43NgR2eXJdNdR1QT5iIkJCmWxrVbpLSHjHhVujZGvtccx

