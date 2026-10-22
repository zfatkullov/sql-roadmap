--
-- PostgreSQL database dump
--

\restrict XYyHdAiL3iU4cd5ZJzghYOvATlFzZbb3GcfIgDbqU9mMOGn0OlnsMwSDpW4kBro

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
-- Name: orders; Type: TABLE; Schema: public; Owner: zaharfatkullov
--

CREATE TABLE public.orders (
    id integer NOT NULL,
    user_id integer NOT NULL,
    amount numeric(10,2) NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT orders_amount_check CHECK ((amount > (0)::numeric))
);


ALTER TABLE public.orders OWNER TO zaharfatkullov;

--
-- Name: orders_id_seq; Type: SEQUENCE; Schema: public; Owner: zaharfatkullov
--

CREATE SEQUENCE public.orders_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.orders_id_seq OWNER TO zaharfatkullov;

--
-- Name: orders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: zaharfatkullov
--

ALTER SEQUENCE public.orders_id_seq OWNED BY public.orders.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: zaharfatkullov
--

CREATE TABLE public.users (
    id integer NOT NULL,
    name text NOT NULL,
    email text
);


ALTER TABLE public.users OWNER TO zaharfatkullov;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: zaharfatkullov
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_id_seq OWNER TO zaharfatkullov;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: zaharfatkullov
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: orders id; Type: DEFAULT; Schema: public; Owner: zaharfatkullov
--

ALTER TABLE ONLY public.orders ALTER COLUMN id SET DEFAULT nextval('public.orders_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: zaharfatkullov
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: zaharfatkullov
--

COPY public.orders (id, user_id, amount, created_at) FROM stdin;
1	1	1500.00	2026-10-15 12:48:49.196419
2	1	320.50	2026-10-15 12:48:49.196419
3	4	2990.00	2026-10-15 12:48:49.196419
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: zaharfatkullov
--

COPY public.users (id, name, email) FROM stdin;
1	Аня	anya@example.com
4	Борис	boris@example.com
5	Вера	vera@example.com
\.


--
-- Name: orders_id_seq; Type: SEQUENCE SET; Schema: public; Owner: zaharfatkullov
--

SELECT pg_catalog.setval('public.orders_id_seq', 3, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: zaharfatkullov
--

SELECT pg_catalog.setval('public.users_id_seq', 5, true);


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: zaharfatkullov
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: zaharfatkullov
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: zaharfatkullov
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: orders orders_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: zaharfatkullov
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- PostgreSQL database dump complete
--

\unrestrict XYyHdAiL3iU4cd5ZJzghYOvATlFzZbb3GcfIgDbqU9mMOGn0OlnsMwSDpW4kBro

