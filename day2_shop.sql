--
-- PostgreSQL database dump
--

\restrict Ywz5s1x1qNuuFDF3HnBt8RC2P5Z5woweROwfU9MKfULMaghNdxDk7n16GvCVe01

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
-- Name: order_items; Type: TABLE; Schema: public; Owner: shop_user
--

CREATE TABLE public.order_items (
    id integer NOT NULL,
    order_id integer NOT NULL,
    product_id integer NOT NULL,
    quantity integer NOT NULL,
    CONSTRAINT order_items_quantity_check CHECK ((quantity > 0))
);


ALTER TABLE public.order_items OWNER TO shop_user;

--
-- Name: order_items_id_seq; Type: SEQUENCE; Schema: public; Owner: shop_user
--

CREATE SEQUENCE public.order_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.order_items_id_seq OWNER TO shop_user;

--
-- Name: order_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: shop_user
--

ALTER SEQUENCE public.order_items_id_seq OWNED BY public.order_items.id;


--
-- Name: products; Type: TABLE; Schema: public; Owner: shop_user
--

CREATE TABLE public.products (
    id integer NOT NULL,
    name text NOT NULL,
    price numeric(10,2) NOT NULL,
    in_stock boolean DEFAULT true NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT products_price_check CHECK ((price > (0)::numeric))
);


ALTER TABLE public.products OWNER TO shop_user;

--
-- Name: products_id_seq; Type: SEQUENCE; Schema: public; Owner: shop_user
--

CREATE SEQUENCE public.products_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.products_id_seq OWNER TO shop_user;

--
-- Name: products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: shop_user
--

ALTER SEQUENCE public.products_id_seq OWNED BY public.products.id;


--
-- Name: shop_orders; Type: TABLE; Schema: public; Owner: shop_user
--

CREATE TABLE public.shop_orders (
    id integer NOT NULL,
    customer text NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.shop_orders OWNER TO shop_user;

--
-- Name: shop_orders_id_seq; Type: SEQUENCE; Schema: public; Owner: shop_user
--

CREATE SEQUENCE public.shop_orders_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.shop_orders_id_seq OWNER TO shop_user;

--
-- Name: shop_orders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: shop_user
--

ALTER SEQUENCE public.shop_orders_id_seq OWNED BY public.shop_orders.id;


--
-- Name: order_items id; Type: DEFAULT; Schema: public; Owner: shop_user
--

ALTER TABLE ONLY public.order_items ALTER COLUMN id SET DEFAULT nextval('public.order_items_id_seq'::regclass);


--
-- Name: products id; Type: DEFAULT; Schema: public; Owner: shop_user
--

ALTER TABLE ONLY public.products ALTER COLUMN id SET DEFAULT nextval('public.products_id_seq'::regclass);


--
-- Name: shop_orders id; Type: DEFAULT; Schema: public; Owner: shop_user
--

ALTER TABLE ONLY public.shop_orders ALTER COLUMN id SET DEFAULT nextval('public.shop_orders_id_seq'::regclass);


--
-- Data for Name: order_items; Type: TABLE DATA; Schema: public; Owner: shop_user
--

COPY public.order_items (id, order_id, product_id, quantity) FROM stdin;
1	1	1	2
2	1	2	1
3	1	3	1
4	2	1	1
5	2	5	3
\.


--
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: shop_user
--

COPY public.products (id, name, price, in_stock, created_at) FROM stdin;
1	Ноутбук	75000.00	t	2026-10-13 18:45:28.367904
2	Мышь	1200.50	t	2026-10-13 18:45:28.367904
4	Монитор	18900.99	t	2026-10-13 18:45:28.367904
6	lunacy	7000.00	t	2026-10-13 18:47:27.621403
9	a	777.00	t	2026-10-14 16:51:49.656167
3	Клавиатура	3850.00	f	2026-10-13 18:45:28.367904
5	Наушники	4620.00	f	2026-10-13 18:45:28.367904
10	b	732.60	f	2026-10-14 16:51:49.656167
\.


--
-- Data for Name: shop_orders; Type: TABLE DATA; Schema: public; Owner: shop_user
--

COPY public.shop_orders (id, customer, created_at) FROM stdin;
1	Аня	2026-10-15 13:08:50.161957
2	Борис	2026-10-15 13:08:50.161957
\.


--
-- Name: order_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: shop_user
--

SELECT pg_catalog.setval('public.order_items_id_seq', 5, true);


--
-- Name: products_id_seq; Type: SEQUENCE SET; Schema: public; Owner: shop_user
--

SELECT pg_catalog.setval('public.products_id_seq', 10, true);


--
-- Name: shop_orders_id_seq; Type: SEQUENCE SET; Schema: public; Owner: shop_user
--

SELECT pg_catalog.setval('public.shop_orders_id_seq', 2, true);


--
-- Name: order_items order_items_pkey; Type: CONSTRAINT; Schema: public; Owner: shop_user
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_pkey PRIMARY KEY (id);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: shop_user
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- Name: shop_orders shop_orders_pkey; Type: CONSTRAINT; Schema: public; Owner: shop_user
--

ALTER TABLE ONLY public.shop_orders
    ADD CONSTRAINT shop_orders_pkey PRIMARY KEY (id);


--
-- Name: order_items order_items_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: shop_user
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.shop_orders(id);


--
-- Name: order_items order_items_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: shop_user
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- PostgreSQL database dump complete
--

\unrestrict Ywz5s1x1qNuuFDF3HnBt8RC2P5Z5woweROwfU9MKfULMaghNdxDk7n16GvCVe01

