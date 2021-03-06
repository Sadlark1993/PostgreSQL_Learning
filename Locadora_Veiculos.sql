PGDMP                      
    w            Locadora_veiculos    9.6.15    9.6.15 E    �           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                       false            �           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                       false            �           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                       false            �           1262    24590    Locadora_veiculos    DATABASE     �   CREATE DATABASE "Locadora_veiculos" WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'Portuguese_Brazil.1252' LC_CTYPE = 'Portuguese_Brazil.1252';
 #   DROP DATABASE "Locadora_veiculos";
             postgres    false                        2615    2200    public    SCHEMA        CREATE SCHEMA public;
    DROP SCHEMA public;
             postgres    false            �           0    0    SCHEMA public    COMMENT     6   COMMENT ON SCHEMA public IS 'standard public schema';
                  postgres    false    3                        3079    12387    plpgsql 	   EXTENSION     ?   CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;
    DROP EXTENSION plpgsql;
                  false            �           0    0    EXTENSION plpgsql    COMMENT     @   COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';
                       false    1            �           1247    24592    sex    TYPE     5   CREATE TYPE public.sex AS ENUM (
    'f',
    'm'
);
    DROP TYPE public.sex;
       public       postgres    false    3            �           1247    24614    tamanho    TYPE     B   CREATE TYPE public.tamanho AS ENUM (
    'p',
    'm',
    'g'
);
    DROP TYPE public.tamanho;
       public       postgres    false    3            �            1255    24787 U   alocar_veiculo(integer, text, integer, timestamp without time zone, integer, integer)    FUNCTION       CREATE FUNCTION public.alocar_veiculo(id_cliente integer, tipo_veiculo text, id_motorista integer, data_entrega timestamp without time zone, filial_locacao integer, filial_entrega integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
declare
i integer = 0;
j integer = 0;
placa_veiculo text;
valor numeric;
dias integer;

begin
if (1<=(select count(*) from locacao_andamento)) then
	i = (select max(id) from locacao_andamento);
end if;
if (1<=(select count(*)from historico_locacao)) then
	j = (select max(id) from historico_locacao);
end if;

if j>i then
	i = j;
end if;

if (localtimestamp >= data_entrega) then
	raise exception 'data inválida';
end if;

if(data_entrega > (select vencimento_cnh from motorista where id = id_motorista)) then
	raise exception 'CNH do motorista vence ou venceu antes do dia de devolucao do veiculo.';
end if;

if (0=(select count(*) from veiculo where tipo = tipo_veiculo)) then
	raise exception 'Nenhum veiculo desse tipo cadastrado';
end if;

if (0 = (select count(*) from veiculo v where tipo = 'P1' and (0 = (select count(*) from historico_locacao where veiculo = v.placa)) and v.filial = filial_locacao)) then
	raise exception 'Nenhum veiculo desse tipo disponivel nessa filial';
end if;

placa_veiculo = (select max(placa) from veiculo v where tipo = 'P1' and (0 = (select count(*) from historico_locacao where veiculo = v.placa)and filial = 1));

valor = (select preco_dia from tipo where id = tipo_veiculo);
dias = (select data_entrega::date - current_date);
valor = valor*dias;

insert into locacao_andamento(id, veiculo, cliente, motorista, data_inicio, data_fim, filial_de_locacao, filial_de_entrega, total_a_pagar)
	values(i, placa_veiculo, id_cliente, id_motorista, localtimestamp, data_entrega, filial_locacao, filial_entrega, valor);

end;
$$;
 �   DROP FUNCTION public.alocar_veiculo(id_cliente integer, tipo_veiculo text, id_motorista integer, data_entrega timestamp without time zone, filial_locacao integer, filial_entrega integer);
       public       postgres    false    1    3            �            1255    24773 :   cadastro_cliente_pf(integer, text, public.sex, text, text)    FUNCTION       CREATE FUNCTION public.cadastro_cliente_pf(tcpf integer, tnome text, tsexo public.sex, taniversario text, tendereco text) RETURNS void
    LANGUAGE plpgsql
    AS $$
declare
i integer = 0;
j integer = 0;
begin
if (1<=(select max(id) from cliente_pf)) then
	i = (select max(id) from cliente_pf);
end if;
if (1<=(select max(id) from cliente_pj)) then
	j = (select max (id) from cliente_pj);
end if;

if i = null then 
	i = 0;
end if;
if j = null then 
	j = 0;
end if;


if i>j then
	i = i+1;
	insert into cliente_pf(id, cpf, nome, sexo, aniversario, endereco) 
		values((select i), tcpf, tnome, tsexo, taniversario, tendereco);
else
	j = j+1;
	insert into cliente_pf(id, cpf, nome, sexo, aniversario, endereco) 
		values((select j), tcpf, tnome, tsexo, taniversario, tendereco);
end if;
end;
$$;
 y   DROP FUNCTION public.cadastro_cliente_pf(tcpf integer, tnome text, tsexo public.sex, taniversario text, tendereco text);
       public       postgres    false    3    495    1            �            1255    24775 .   cadastro_cliente_pj(integer, text, text, text)    FUNCTION     �  CREATE FUNCTION public.cadastro_cliente_pj(cnpj integer, tie text, tendereco text, tnome text) RETURNS void
    LANGUAGE plpgsql
    AS $$
declare
i integer = 0;
j integer = 0;
begin
if (1<=(select max(id) from cliente_pf)) then
	i = (select max(id) from cliente_pf);
end if;
if (i<=(select max(id) from cliente_pj)) then
	j = (select max (id) from cliente_pj);
end if;

if i = null then
	i = 0;
end if;
if j = null then
	j = 0;
end if;

if i>j then
	insert into cliente_pj(id, cnpj, ie, endereco, nome) 
		values((i+1), cnpj, tie, tendereco, tnome);
else
	insert into cliente_pj(id, cnpj, ie, endereco, nome) 
		values((j+1), cnpj, tie, tendereco, tnome);
end if;
end;
$$;
 ^   DROP FUNCTION public.cadastro_cliente_pj(cnpj integer, tie text, tendereco text, tnome text);
       public       postgres    false    1    3            �            1255    24778    gravar_historico_locacao()    FUNCTION     �  CREATE FUNCTION public.gravar_historico_locacao() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
insert into historico_locacao(id, veiculo, cliente, motorista, data_inicio, data_fim, filial_de_locacao, filial_de_entrega, total_pago)
	values(old.id, old.veiculo, old.cliente, old.motorista, old.data_inicio, old.data_fim, old.filial_de_locacao, old.filial_de_entrega, old.total_a_pagar);
return OLD;
end;
$$;
 1   DROP FUNCTION public.gravar_historico_locacao();
       public       postgres    false    3    1            �            1255    24776    gravar_historico_manut()    FUNCTION     �   CREATE FUNCTION public.gravar_historico_manut() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
insert into historico_manutencao(id, veiculo, data_inicio, data_fim) values(old.id, old.veiculo, old.data_inicio, old.data_fim);
return new;
end;
$$;
 /   DROP FUNCTION public.gravar_historico_manut();
       public       postgres    false    3    1            �            1259    24597 
   cliente_pf    TABLE     �   CREATE TABLE public.cliente_pf (
    id integer NOT NULL,
    cpf integer NOT NULL,
    nome text NOT NULL,
    sexo public.sex,
    aniversario text,
    endereco text
);
    DROP TABLE public.cliente_pf;
       public         postgres    false    3    495            �            1259    24605 
   cliente_pj    TABLE     �   CREATE TABLE public.cliente_pj (
    id integer NOT NULL,
    cnpj integer NOT NULL,
    ie text,
    endereco text,
    nome text NOT NULL
);
    DROP TABLE public.cliente_pj;
       public         postgres    false    3            �            1259    24690    filial    TABLE     n   CREATE TABLE public.filial (
    id integer NOT NULL,
    cidade text NOT NULL,
    endereco text NOT NULL
);
    DROP TABLE public.filial;
       public         postgres    false    3            �            1259    24688    filial_id_seq    SEQUENCE     v   CREATE SEQUENCE public.filial_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 $   DROP SEQUENCE public.filial_id_seq;
       public       postgres    false    195    3            �           0    0    filial_id_seq    SEQUENCE OWNED BY     ?   ALTER SEQUENCE public.filial_id_seq OWNED BY public.filial.id;
            public       postgres    false    194            �            1259    24727    historico_locacao    TABLE     R  CREATE TABLE public.historico_locacao (
    id integer NOT NULL,
    veiculo text,
    cliente integer NOT NULL,
    motorista integer,
    data_inicio timestamp without time zone NOT NULL,
    data_fim timestamp without time zone NOT NULL,
    filial_de_locacao integer,
    filial_de_entrega integer,
    total_pago numeric NOT NULL
);
 %   DROP TABLE public.historico_locacao;
       public         postgres    false    3            �            1259    24664    historico_manutencao    TABLE     �   CREATE TABLE public.historico_manutencao (
    id integer NOT NULL,
    veiculo text,
    data_inicio timestamp without time zone,
    data_fim timestamp without time zone
);
 (   DROP TABLE public.historico_manutencao;
       public         postgres    false    3            �            1259    24699    locacao_andamento    TABLE     U  CREATE TABLE public.locacao_andamento (
    id integer NOT NULL,
    veiculo text,
    cliente integer NOT NULL,
    motorista integer,
    data_inicio timestamp without time zone NOT NULL,
    data_fim timestamp without time zone NOT NULL,
    filial_de_locacao integer,
    filial_de_entrega integer,
    total_a_pagar numeric NOT NULL
);
 %   DROP TABLE public.locacao_andamento;
       public         postgres    false    3            �            1259    24650    manutencao_andamento    TABLE     �   CREATE TABLE public.manutencao_andamento (
    veiculo text,
    data_inicio timestamp without time zone,
    data_fim timestamp without time zone,
    id integer NOT NULL
);
 (   DROP TABLE public.manutencao_andamento;
       public         postgres    false    3            �            1259    24679 	   motorista    TABLE     �   CREATE TABLE public.motorista (
    id integer NOT NULL,
    cpf integer NOT NULL,
    cnh text NOT NULL,
    vencimento_cnh timestamp without time zone NOT NULL,
    nome text NOT NULL
);
    DROP TABLE public.motorista;
       public         postgres    false    3            �            1259    24677    motorista_id_seq    SEQUENCE     y   CREATE SEQUENCE public.motorista_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 '   DROP SEQUENCE public.motorista_id_seq;
       public       postgres    false    193    3            �           0    0    motorista_id_seq    SEQUENCE OWNED BY     E   ALTER SEQUENCE public.motorista_id_seq OWNED BY public.motorista.id;
            public       postgres    false    192            �            1259    24642 	   telefones    TABLE     _   CREATE TABLE public.telefones (
    id_cliente integer NOT NULL,
    telefone text NOT NULL
);
    DROP TABLE public.telefones;
       public         postgres    false    3            �            1259    24621    tipo    TABLE     �  CREATE TABLE public.tipo (
    id text NOT NULL,
    tam public.tamanho NOT NULL,
    passageiros integer NOT NULL,
    portas integer NOT NULL,
    preco_dia numeric NOT NULL,
    ar_condicionado boolean NOT NULL,
    radio boolean NOT NULL,
    cd boolean NOT NULL,
    mp3 boolean NOT NULL,
    direcao_hidraulica boolean NOT NULL,
    cambio_auto boolean NOT NULL,
    carga integer,
    tempo_limpeza_revisao time without time zone NOT NULL
);
    DROP TABLE public.tipo;
       public         postgres    false    3    498            �            1259    24629    veiculo    TABLE     �   CREATE TABLE public.veiculo (
    placa text NOT NULL,
    chassi text NOT NULL,
    motor text NOT NULL,
    tipo text,
    cor text,
    km_rodados integer,
    filial integer
);
    DROP TABLE public.veiculo;
       public         postgres    false    3                       2604    24693 	   filial id    DEFAULT     f   ALTER TABLE ONLY public.filial ALTER COLUMN id SET DEFAULT nextval('public.filial_id_seq'::regclass);
 8   ALTER TABLE public.filial ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    194    195    195                       2604    24682    motorista id    DEFAULT     l   ALTER TABLE ONLY public.motorista ALTER COLUMN id SET DEFAULT nextval('public.motorista_id_seq'::regclass);
 ;   ALTER TABLE public.motorista ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    193    192    193            �          0    24597 
   cliente_pf 
   TABLE DATA               P   COPY public.cliente_pf (id, cpf, nome, sexo, aniversario, endereco) FROM stdin;
    public       postgres    false    185   �c       �          0    24605 
   cliente_pj 
   TABLE DATA               B   COPY public.cliente_pj (id, cnpj, ie, endereco, nome) FROM stdin;
    public       postgres    false    186   yd       �          0    24690    filial 
   TABLE DATA               6   COPY public.filial (id, cidade, endereco) FROM stdin;
    public       postgres    false    195   �d       �           0    0    filial_id_seq    SEQUENCE SET     ;   SELECT pg_catalog.setval('public.filial_id_seq', 1, true);
            public       postgres    false    194            �          0    24727    historico_locacao 
   TABLE DATA               �   COPY public.historico_locacao (id, veiculo, cliente, motorista, data_inicio, data_fim, filial_de_locacao, filial_de_entrega, total_pago) FROM stdin;
    public       postgres    false    197   Ge       �          0    24664    historico_manutencao 
   TABLE DATA               R   COPY public.historico_manutencao (id, veiculo, data_inicio, data_fim) FROM stdin;
    public       postgres    false    191   de       �          0    24699    locacao_andamento 
   TABLE DATA               �   COPY public.locacao_andamento (id, veiculo, cliente, motorista, data_inicio, data_fim, filial_de_locacao, filial_de_entrega, total_a_pagar) FROM stdin;
    public       postgres    false    196   �e       �          0    24650    manutencao_andamento 
   TABLE DATA               R   COPY public.manutencao_andamento (veiculo, data_inicio, data_fim, id) FROM stdin;
    public       postgres    false    190   �e       �          0    24679 	   motorista 
   TABLE DATA               G   COPY public.motorista (id, cpf, cnh, vencimento_cnh, nome) FROM stdin;
    public       postgres    false    193   �e       �           0    0    motorista_id_seq    SEQUENCE SET     >   SELECT pg_catalog.setval('public.motorista_id_seq', 3, true);
            public       postgres    false    192            �          0    24642 	   telefones 
   TABLE DATA               9   COPY public.telefones (id_cliente, telefone) FROM stdin;
    public       postgres    false    189   �f       �          0    24621    tipo 
   TABLE DATA               �   COPY public.tipo (id, tam, passageiros, portas, preco_dia, ar_condicionado, radio, cd, mp3, direcao_hidraulica, cambio_auto, carga, tempo_limpeza_revisao) FROM stdin;
    public       postgres    false    187   �f       �          0    24629    veiculo 
   TABLE DATA               V   COPY public.veiculo (placa, chassi, motor, tipo, cor, km_rodados, filial) FROM stdin;
    public       postgres    false    188   
g                  2606    24604    cliente_pf cliente_pf_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY public.cliente_pf
    ADD CONSTRAINT cliente_pf_pkey PRIMARY KEY (id);
 D   ALTER TABLE ONLY public.cliente_pf DROP CONSTRAINT cliente_pf_pkey;
       public         postgres    false    185    185                       2606    24612    cliente_pj cliente_pj_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY public.cliente_pj
    ADD CONSTRAINT cliente_pj_pkey PRIMARY KEY (id);
 D   ALTER TABLE ONLY public.cliente_pj DROP CONSTRAINT cliente_pj_pkey;
       public         postgres    false    186    186            "           2606    24698    filial filial_pkey 
   CONSTRAINT     P   ALTER TABLE ONLY public.filial
    ADD CONSTRAINT filial_pkey PRIMARY KEY (id);
 <   ALTER TABLE ONLY public.filial DROP CONSTRAINT filial_pkey;
       public         postgres    false    195    195            &           2606    24734 (   historico_locacao historico_locacao_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public.historico_locacao
    ADD CONSTRAINT historico_locacao_pkey PRIMARY KEY (id);
 R   ALTER TABLE ONLY public.historico_locacao DROP CONSTRAINT historico_locacao_pkey;
       public         postgres    false    197    197                       2606    24671 .   historico_manutencao historico_manutencao_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY public.historico_manutencao
    ADD CONSTRAINT historico_manutencao_pkey PRIMARY KEY (id);
 X   ALTER TABLE ONLY public.historico_manutencao DROP CONSTRAINT historico_manutencao_pkey;
       public         postgres    false    191    191            $           2606    24706 (   locacao_andamento locacao_andamento_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public.locacao_andamento
    ADD CONSTRAINT locacao_andamento_pkey PRIMARY KEY (id);
 R   ALTER TABLE ONLY public.locacao_andamento DROP CONSTRAINT locacao_andamento_pkey;
       public         postgres    false    196    196                       2606    24762 .   manutencao_andamento manutencao_andamento_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY public.manutencao_andamento
    ADD CONSTRAINT manutencao_andamento_pkey PRIMARY KEY (id);
 X   ALTER TABLE ONLY public.manutencao_andamento DROP CONSTRAINT manutencao_andamento_pkey;
       public         postgres    false    190    190                        2606    24687    motorista motorista_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY public.motorista
    ADD CONSTRAINT motorista_pkey PRIMARY KEY (id);
 B   ALTER TABLE ONLY public.motorista DROP CONSTRAINT motorista_pkey;
       public         postgres    false    193    193                       2606    24628    tipo tipo_pkey 
   CONSTRAINT     L   ALTER TABLE ONLY public.tipo
    ADD CONSTRAINT tipo_pkey PRIMARY KEY (id);
 8   ALTER TABLE ONLY public.tipo DROP CONSTRAINT tipo_pkey;
       public         postgres    false    187    187                       2606    24636    veiculo veiculo_pkey 
   CONSTRAINT     U   ALTER TABLE ONLY public.veiculo
    ADD CONSTRAINT veiculo_pkey PRIMARY KEY (placa);
 >   ALTER TABLE ONLY public.veiculo DROP CONSTRAINT veiculo_pkey;
       public         postgres    false    188    188            4           2620    24779     locacao_andamento gravar_locacao    TRIGGER     �   CREATE TRIGGER gravar_locacao BEFORE DELETE ON public.locacao_andamento FOR EACH ROW EXECUTE PROCEDURE public.gravar_historico_locacao();
 9   DROP TRIGGER gravar_locacao ON public.locacao_andamento;
       public       postgres    false    196    199            3           2620    24777 !   manutencao_andamento gravar_manut    TRIGGER     �   CREATE TRIGGER gravar_manut BEFORE DELETE ON public.manutencao_andamento FOR EACH ROW EXECUTE PROCEDURE public.gravar_historico_manut();
 :   DROP TRIGGER gravar_manut ON public.manutencao_andamento;
       public       postgres    false    198    190            2           2606    24750 :   historico_locacao historico_locacao_filial_de_entrega_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.historico_locacao
    ADD CONSTRAINT historico_locacao_filial_de_entrega_fkey FOREIGN KEY (filial_de_entrega) REFERENCES public.filial(id);
 d   ALTER TABLE ONLY public.historico_locacao DROP CONSTRAINT historico_locacao_filial_de_entrega_fkey;
       public       postgres    false    197    195    2082            1           2606    24745 :   historico_locacao historico_locacao_filial_de_locacao_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.historico_locacao
    ADD CONSTRAINT historico_locacao_filial_de_locacao_fkey FOREIGN KEY (filial_de_locacao) REFERENCES public.filial(id);
 d   ALTER TABLE ONLY public.historico_locacao DROP CONSTRAINT historico_locacao_filial_de_locacao_fkey;
       public       postgres    false    197    2082    195            0           2606    24740 2   historico_locacao historico_locacao_motorista_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.historico_locacao
    ADD CONSTRAINT historico_locacao_motorista_fkey FOREIGN KEY (motorista) REFERENCES public.motorista(id);
 \   ALTER TABLE ONLY public.historico_locacao DROP CONSTRAINT historico_locacao_motorista_fkey;
       public       postgres    false    193    2080    197            /           2606    24735 0   historico_locacao historico_locacao_veiculo_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.historico_locacao
    ADD CONSTRAINT historico_locacao_veiculo_fkey FOREIGN KEY (veiculo) REFERENCES public.veiculo(placa);
 Z   ALTER TABLE ONLY public.historico_locacao DROP CONSTRAINT historico_locacao_veiculo_fkey;
       public       postgres    false    188    197    2074            *           2606    24672 6   historico_manutencao historico_manutencao_veiculo_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.historico_manutencao
    ADD CONSTRAINT historico_manutencao_veiculo_fkey FOREIGN KEY (veiculo) REFERENCES public.veiculo(placa);
 `   ALTER TABLE ONLY public.historico_manutencao DROP CONSTRAINT historico_manutencao_veiculo_fkey;
       public       postgres    false    191    2074    188            .           2606    24722 :   locacao_andamento locacao_andamento_filial_de_entrega_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.locacao_andamento
    ADD CONSTRAINT locacao_andamento_filial_de_entrega_fkey FOREIGN KEY (filial_de_entrega) REFERENCES public.filial(id);
 d   ALTER TABLE ONLY public.locacao_andamento DROP CONSTRAINT locacao_andamento_filial_de_entrega_fkey;
       public       postgres    false    195    2082    196            -           2606    24717 :   locacao_andamento locacao_andamento_filial_de_locacao_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.locacao_andamento
    ADD CONSTRAINT locacao_andamento_filial_de_locacao_fkey FOREIGN KEY (filial_de_locacao) REFERENCES public.filial(id);
 d   ALTER TABLE ONLY public.locacao_andamento DROP CONSTRAINT locacao_andamento_filial_de_locacao_fkey;
       public       postgres    false    2082    195    196            ,           2606    24712 2   locacao_andamento locacao_andamento_motorista_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.locacao_andamento
    ADD CONSTRAINT locacao_andamento_motorista_fkey FOREIGN KEY (motorista) REFERENCES public.motorista(id);
 \   ALTER TABLE ONLY public.locacao_andamento DROP CONSTRAINT locacao_andamento_motorista_fkey;
       public       postgres    false    2080    193    196            +           2606    24707 0   locacao_andamento locacao_andamento_veiculo_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.locacao_andamento
    ADD CONSTRAINT locacao_andamento_veiculo_fkey FOREIGN KEY (veiculo) REFERENCES public.veiculo(placa);
 Z   ALTER TABLE ONLY public.locacao_andamento DROP CONSTRAINT locacao_andamento_veiculo_fkey;
       public       postgres    false    188    2074    196            )           2606    24659 6   manutencao_andamento manutencao_andamento_veiculo_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.manutencao_andamento
    ADD CONSTRAINT manutencao_andamento_veiculo_fkey FOREIGN KEY (veiculo) REFERENCES public.veiculo(placa);
 `   ALTER TABLE ONLY public.manutencao_andamento DROP CONSTRAINT manutencao_andamento_veiculo_fkey;
       public       postgres    false    2074    188    190            (           2606    24756    veiculo veiculo_filial_fkey    FK CONSTRAINT     z   ALTER TABLE ONLY public.veiculo
    ADD CONSTRAINT veiculo_filial_fkey FOREIGN KEY (filial) REFERENCES public.filial(id);
 E   ALTER TABLE ONLY public.veiculo DROP CONSTRAINT veiculo_filial_fkey;
       public       postgres    false    2082    195    188            '           2606    24637    veiculo veiculo_tipo_fkey    FK CONSTRAINT     t   ALTER TABLE ONLY public.veiculo
    ADD CONSTRAINT veiculo_tipo_fkey FOREIGN KEY (tipo) REFERENCES public.tipo(id);
 C   ALTER TABLE ONLY public.veiculo DROP CONSTRAINT veiculo_tipo_fkey;
       public       postgres    false    187    188    2072            �   �   x�=���0���S��$M�vfCTB���ڄ*�MP~���Ȓ���AwC�@�ݭ;�R7\C,�&$��Tݗ�ƀ�IЪ�R0R�kr���m<�����y:�Z���Sp��R�Z^J���D����b(��Fc�q�)1������g�i]�TŹh������������=�      �   k   x�3�435"SNOWC# �t,K��LITp*J,��Q02��+-)�Lrs2sS�J��8ML�,̌�,�A���u�&&'�''r:���%g&*�e��q��qqq �       �   C   x�3��/*�Wp�IM/J�*MTI�Q�+�M-�W��2�t��/�L��/���,+�I�s��qqq �/G      �      x������ � �      �      x������ � �      �   F   x���� �d
 ]��Jf�v��b��'S��V͔������j#��C�k�2ro�
q8��A�."ML      �      x������ � �      �   }   x�U��
A���S�"��,jk}(�6�ÅU��齟B�f���t�I�hĆ1��1��<��$�*'[�!f��Wh��i^��^���<�3��A-M̱��XH��m���o}�� >n0&�      �   !   x�3�443!.#NKK0Ӑ�ʊ���� r��      �   H   x�0���4BC=�0L�?NS+ �
0��3ARW���ݐ3�ӂӜ��M]	X�T]�  �8      �   �   x�M�A
�0E�?��	�3&Q���J]��X쪴E"����n�o���]�|_��87�eO���H=�Y3�B_;k���Y�Ȣc|�)�7�+��m��E��ř3��q���N�%i6E��eW�Y�d�A�*�EK�p���[;�Su4����R��/�     