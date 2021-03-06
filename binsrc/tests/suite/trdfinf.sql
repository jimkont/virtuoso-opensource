
sparql clear graph 'inft';


ttlp ('
<ic1> a <c1> .
<ic2> a <c2> .
<ic3> a <c3> .
<ic1> <p1> <ic1p1> .
<ic2> <p1> <ic2p1>.
<ic3> <p1> <ic3p1> .
<ic1> <cl2> <c2> .
<subj11-l1> <pd11> <subj11-r1> .
<subj11-r2> <pi11> <subj11-l2> .
<subj11-r3> <pi12> <subj11-l3> .
<subj22-1> <pd22> <subj22-2> .
<subj-t1-1> <pt1> <subj-t1-11> .
<subj-t1-1> <pt1> <subj-t1-12> .
<subj-t1-11> <pt1> <subj-t1-111> .
<subj-t1-11> <pt1> <subj-t1-112> .
<subj-t1-12> <pt1> <subj-t1-121> .
<subj-t1-12> <pt1> <subj-t1-122> .
<subj-t1-111> <pt1> <subj-t1-1111> .
<subj-t1-111> <pt1> <subj-t1-1121> .
<subj-t1-121> <pt1> <subj-t1-1211> .
<subj-t1-121> <pt1> <subj-t1-1221> .
<subj-dt1-1> <pdt1> <subj-dt1-11> .
<subj-dt1-1> <pdt1> <subj-dt1-12> .
<subj-dt1-11> <pdt1> <subj-dt1-111> .
<subj-dt1-11> <pdt1> <subj-dt1-112> .
<subj-dt1-12> <pdt1> <subj-dt1-121> .
<subj-dt1-12> <pdt1> <subj-dt1-122> .
', '', 'inft');

ttlp ('
<ic1> <icpe> 1 .
<ic2> <icpe> 2 .
<ic3> <icpe> 3 .
<ic4> <icpe> 4 .
', '', 'extra');


ttlp (' @prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
@prefix owl: <http://www.w3.org/2002/07/owl#> .
<c2> rdfs:subClassOf <c1> .
  <c3> rdfs:subClassOf <c2> .
  <c5> rdfs:subClassOf <c4> .
<p1> rdfs:subPropertyOf <p0> .
<pi11> owl:inverseOf <pd11> .
<pi12> owl:inverseOf <pd11> .
<pd11> owl:inverseOf <pi11> .
<pd22> a owl:SymmetricProperty .
<pdt1> a owl:SymmetricProperty, owl:TransitiveProperty .
<pt1> a owl:TransitiveProperty .
', '', 'sc');

create procedure f (in q any) {return q;};

rdfs_rule_set ('inft', 'sc');

sparql define input:inference 'inft' select * from <inft> where { ?s <pd11> ?o };
ECHO BOTH $IF $EQU $ROWCNT 3 "PASSED" "***FAILED";
ECHO BOTH ": 3 rows with pd11 and 2 inverses, pi11 and pi12\n";

sparql define input:inference 'inft' select * from <inft> where { ?s <pi11> ?o };
ECHO BOTH $IF $EQU $ROWCNT 2 "PASSED" "***FAILED";
ECHO BOTH ": 2 rows with pi11 and 1 inverse, pd11\n";

sparql define input:inference 'inft' select * from <inft> where { ?s <pi12> ?o };
ECHO BOTH $IF $EQU $ROWCNT 2 "PASSED" "***FAILED";
ECHO BOTH ": 2 rows with pi12 and 1 inverse, pd11\n";

sparql define input:inference 'inft' select * from <inft> where { ?s <pd22> ?o };
ECHO BOTH $IF $EQU $ROWCNT 2 "PASSED" "***FAILED";
ECHO BOTH ": 2 rows with symmetric pd22\n";

sparql define input:inference 'inft' select * from <inft> where { ?s  <pt1> ?o . filter (?s = <subj-t1-11>) };
ECHO BOTH $IF $EQU $ROWCNT 4 "PASSED" "***FAILED";
ECHO BOTH ": 4 rows with unidirectional transitive pt1\n";

sparql define input:inference 'inft' select * from <inft> where { ?s  <pdt1> ?o option (T_DISTINCT) . filter (?s = <subj-dt1-11>) };
ECHO BOTH $IF $EQU $ROWCNT 6 "PASSED" "***FAILED";
ECHO BOTH ": 6 rows with symmetric transitive pdt1\n";

select id_to_iri (s) from rdf_quad table option (with 'inft') where g = iri_to_id ('inft',0) and p = iri_to_id ('http://www.w3.org/1999/02/22-rdf-syntax-ns#type', 0) and o = iri_to_id ('c1', 0);
ECHO BOTH $IF $EQU $ROWCNT 3 "PASSED" "***FAILED";
ECHO BOTH ":  3 inst of c1 without f \n";

select id_to_iri (s) from rdf_quad table option (with 'inft') where g = iri_to_id ('inft',0) and p = f (iri_to_id ('http://www.w3.org/1999/02/22-rdf-syntax-ns#type', 0)) and o = f (iri_to_id ('c1', 0));
ECHO BOTH $IF $EQU $ROWCNT 3 "PASSED" "***FAILED";
ECHO BOTH ":  3 inst of c1 with f \n";


select id_to_iri (s), id_to_iri (p), id_to_iri (o) from rdf_quad table option (with 'inft') where g = iri_to_id ('inft', 0);
ECHO BOTH $IF $EQU $ROWCNT 33 "PASSED" "***FAILED";
ECHO BOTH ": 33 triples in g inft\n";



select id_to_iri (a.s) from rdf_quad a table option (with 'inft'), rdf_quad b table option (with 'inft')
where a.g = iri_to_id ('inft', 0) and b.g = iri_to_id ('inft', 0)
	and a.o = iri_to_id ('c1', 0) and b.o = iri_to_id ('c1', 0)
	and a.p = iri_to_id ('http://www.w3.org/1999/02/22-rdf-syntax-ns#type', 0)
	and b.p = iri_to_id ('http://www.w3.org/1999/02/22-rdf-syntax-ns#type', 0)
	and a.s = b.s;

ECHO BOTH $IF $EQU $ROWCNT 3 "PASSED" "***FAILED";
ECHO BOTH ": inx int on o = c1 and p = rdfs:type\n";


explain ('select 1 from rdf_quad a table option (with ''inft''), rdf_quad b table option (with ''inft '')
where a.g = iri_to_id (''inft'', 0) and b.g = iri_to_id (''inft'', 0)
	and a.o = iri_to_id (''c1'', 0) and b.o = iri_to_id (''c1'', 0)
	and a.p = iri_to_id (''http://www.w3.org/1999/02/22-rdf-syntax-ns#type'', 0)
	and b.p = iri_to_id (''http://www.w3.org/1999/02/22-rdf-syntax-ns#type'', 0)
	and a.s = b.s', -5);



select s, p from rdf_quad table option (with 'inft')
where g = iri_to_id ('inft', 0) and o = iri_to_id ('c1', 0);
ECHO BOTH $IF $EQU $ROWCNT 3 "PASSED" "***FAILED";
ECHO BOTH ": o = c1 3 rows\n";


create table ps (ps iri_id primary key);

insert into ps values (iri_to_id ('c1', 1));
insert into ps values (iri_to_id ('c4', 1));

select ps, s, p, o from ps left join  rdf_quad table option (with 'inft') on g = iri_to_id ('inft', 0) and  ps  = o;
ECHO BOTH $IF $EQU $ROWCNT 4 "PASSED" "***FAILED";
ECHO BOTH ": inf oj rowcnt\n";



--- Complete combinations
--- fs fp fo
select id_to_iri (s), id_to_iri (p), id_to_iri (o)  from rdf_quad table option (with 'inft') where g = iri_to_id ('inft', 0);
ECHO BOTH $IF $EQU $ROWCNT 33 "PASSED" "***FAILED";
ECHO BOTH ": fs fp fp \n";

select id_to_iri (s), id_to_iri (p), id_to_iri (o)  from rdf_quad table option (with 'inft') where g = iri_to_id ('inft', 0) and o = iri_to_id ('c1', 0);
ECHO BOTH $IF $EQU $ROWCNT 3 "PASSED" "***FAILED";
ECHO BOTH ": fs fp go = c1 \n";

select id_to_iri (s), id_to_iri (p), id_to_iri (o)  from rdf_quad table option (with 'inft') where g = iri_to_id ('inft', 0) and o = f (iri_to_id ('c1', 0));
ECHO BOTH $IF $EQU $ROWCNT 3 "PASSED" "***FAILED";
ECHO BOTH ": fs fp go = f c1 \n";

select id_to_iri (s), id_to_iri (p), id_to_iri (o)  from rdf_quad table option (with 'inft') where g = iri_to_id ('inft', 0) and o = f (iri_to_id ('ic1p1', 0));
ECHO BOTH $IF $EQU $ROWCNT 2 "PASSED" "***FAILED";
ECHO BOTH ": fs fp go = f ic1p1 \n";


select id_to_iri (s), id_to_iri (p), id_to_iri (o)  from rdf_quad table option (with 'inft') where g = iri_to_id ('inft', 0) and p = iri_to_id ('http://www.w3.org/1999/02/22-rdf-syntax-ns#type', 0);
ECHO BOTH $IF $EQU $ROWCNT 6 "PASSED" "***FAILED";
ECHO BOTH ": fs gp = rdfstype fo \n";

select id_to_iri (s), id_to_iri (p), id_to_iri (o)  from rdf_quad table option (with 'inft') where g = iri_to_id ('inft', 0) and p = f (iri_to_id ('http://www.w3.org/1999/02/22-rdf-syntax-ns#type', 0));
ECHO BOTH $IF $EQU $ROWCNT 6 "PASSED" "***FAILED";
ECHO BOTH ": fs gp = f rdfstype fo \n";


select id_to_iri (s), id_to_iri (p), id_to_iri (o)  from rdf_quad table option (with 'inft') where g = iri_to_id ('inft', 0) and p = f (iri_to_id ('p0', 0));
ECHO BOTH $IF $EQU $ROWCNT 3 "PASSED" "***FAILED";
ECHO BOTH ": fs gp = f p0 fo \n";

select id_to_iri (s), id_to_iri (p), id_to_iri (o)  from rdf_quad table option (with 'inft') where g = iri_to_id ('inft', 0) and p = iri_to_id ('p0', 0);
ECHO BOTH $IF $EQU $ROWCNT 3 "PASSED" "***FAILED";
ECHO BOTH ": fs gp =  p0 fo \n";


-- fs gp go

select id_to_iri (s), id_to_iri (p), id_to_iri (o)  from rdf_quad table option (with 'inft') where g = iri_to_id ('inft', 0) and p = iri_to_id ('p0', 0) and o = iri_to_id ('ic1p1',0);
ECHO BOTH $IF $EQU $ROWCNT 1 "PASSED" "***FAILED";
ECHO BOTH ": fs gp =  p0 go = ic1p1  \n";

select id_to_iri (s), id_to_iri (p), id_to_iri (o)  from rdf_quad table option (with 'inft') where g = iri_to_id ('inft', 0) and p = iri_to_id ('http://www.w3.org/1999/02/22-rdf-syntax-ns#type', 0) and o = iri_to_id ('c2',0);
ECHO BOTH $IF $EQU $ROWCNT 2 "PASSED" "***FAILED";
ECHO BOTH ": fs gp =  rdfstype  go = c2  \n";


sparql define input:inference  'inft' select ?s ?p from <inft> where { ?s ?p <c1> . };
ECHO BOTH $IF $EQU $ROWCNT 3 "PASSED" "***FAILED";
ECHO BOTH ": fs fp go with  sparql\n";

sparql define input:inference  'inft' select * from <inft> where { ?s ?p <c1> . ?s ?p1 <ic2p1> . };
ECHO BOTH $IF $EQU $ROWCNT 2 "PASSED" "***FAILED";
ECHO BOTH ": fs fp go join fs fp go with  sparql\n";

sparql define input:inference  'inft' select * from <inft> where { ?s ?p <c1> . ?s ?p1 <ic2p1> option (inference 'none') . };
ECHO BOTH $IF $NEQ $STATE OK "PASSED" "***FAILED";
ECHO BOTH ": fs fp go join fs fp go with  sparql inf none STATE=" $STATE " MESSAGE=" $MESSAGE "\n" ;

sparql  select * from <inft> where { ?s ?p <c1> option (inference 'inft') . ?s ?p1 <ic2p1> . };
ECHO BOTH $IF $EQU $ROWCNT 1 "PASSED" "***FAILED";
ECHO BOTH ": fs fp go join fs fp go with  sparql inf inft\n";

sparql define input:inference 'inft' select count (*) from <inft> where {?s ?p ?o};

sparql define input:inference 'inft' select ?p count (?o) from <inft> where {?s ?p ?o};

sparql define input:inference 'inft' select count (?p) count (?o) count (distinct ?o)  from <inft> where {?s ?p ?o};

sparql select count distinct ?s ?p ?o from <g> where {?s ?p ?o};


sparql define input:inference 'inft' select ?s ?p count  (?o) from <inft> from <extra> where {?s ?p ?o};

sparql define input:inference 'inft'
select ?icpe ?cl from <inft> from <extra> where { ?icpe <icpe> ?v . optional { ?icpe a ?cl } };
ECHO BOTH $IF $EQU $ROWCNT 7 "PASSED" "***FAILED";
ECHO BOTH ": 2 graph oj \n";


ttlp (
'<syn1-c1> <http://www.w3.org/2002/07/owl#sameAs> <ic1> .
<ic1> <http://www.w3.org/2002/07/owl#sameAs> <syn2-ic1> .
<syn2-ic1> <http://www.w3.org/2002/07/owl#sameAs> <syn3-ic1> .
<syn4-ic1> <http://www.w3.org/2002/07/owl#sameAs> <syn3-ic1> .
<syn4-ic1> <http://www.w3.org/2002/07/owl#sameAs> <ic1> .
<syn2-ic1> <psyn2> 2 .
', '', 'sas', 0);


sparql define input:inference 'inft'
select ?cl from <inft> from <sas> where { <syn3-ic1> a ?cl };
--ECHO BOTH $IF $EQU $LAST[1] c1 "PASSED" "***FAILED";
--ECHO BOTH ": same-as with class\n";

sparql define input:inference 'inft'
select ?p ?o  from <inft> from <sas> where { <syn3-ic1> ?p ?o };
--ECHO BOTH $IF $EQU $ROWCNT 10 "PASSED" "***FAILED";
--ECHO BOTH ": properties following same-as\n";


sparql define input:inference 'inft'
select ?s from <inft> from <sas> where { ?s <p1> <ic1p1> };


ttlp (' @prefix owl: <http://www.w3.org/2002/07/owl#> .
 @prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
#<c2> rdfs:subClassOf <c1> .
<p2> rdfs:subPropertyOf <p1> .
<p1> rdfs:subPropertyOf <p0> .
#<sas-ic1> owl:sameAs <ic1> .
<sas-p1>  owl:sameAs <p1> .
<sas-p12>  owl:sameAs <sas-p1> .
<ic1> a <c1> .
#<ic2> a <c2> .
<ic1> <p1> <ic1p1> .
<ic1> <p2> <ic1p2> .
<ic1> <sas-p1> <ic1sas-p1> .
#<ic2> <p1> <ic2p1> .
', '', 'sas-p');

rdfs_rule_set ('sas-p', 'sas-p');

sparql define input:inference 'sas-p' define input:same-as "yes"
select * from <sas-p> where { ?s <p0> ?o };
ECHO BOTH $IF $EQU $ROWCNT 3 "PASSED" "***FAILED";
ECHO BOTH ": same-as for super property\n";

sparql define input:inference 'sas-p' define input:same-as "yes"
select distinct * from <sas-p> where { ?s <p1> ?o };
ECHO BOTH $IF $EQU $ROWCNT 3 "PASSED" "***FAILED";
ECHO BOTH ": same-as for property\n";

sparql define input:inference 'sas-p' define input:same-as "yes"
select distinct * from <sas-p> where { ?s <sas-p1> ?o };
ECHO BOTH $IF $EQU $ROWCNT 3 "PASSED" "***FAILED";
ECHO BOTH ": same-as for sameAs property\n";


create procedure s_list (in ctx varchare, in iri varchar, in axis int)
{
  declare inx, a any;
  a := rdf_super_sub_list (ctx, iri_to_id (iri), axis);
  result_names 	(iri);
  for (inx := 0;	 inx < length (a); inx := inx + 1)
    result (id_to_iri (a[inx]));
}

sparql clear graph <g1>;
sparql clear graph <g2>;
sparql clear graph <g3>;
sparql insert data in <g1> { <s1> <p> 1; <q> 10 . };                                                           
sparql insert data in <g2> { <s2> <p> 2; <q> 20 . };
sparql insert data in <g3> { <s3> <p> 3; <q> 30 . };

sparql select * where { graph ?g { ?s ?p ?o . filter (?g = <g3>) }};
ECHO BOTH $IF $EQU $ROWCNT 2 "PASSED" "***FAILED";
ECHO BOTH ": 2 rows filter (?g = <g3>) \n";

sparql select * where { graph ?g { ?s <p> ?o . filter (?g = <g1>) }};
ECHO BOTH $IF $EQU $ROWCNT 1 "PASSED" "***FAILED";
ECHO BOTH ": 1 row { ?s <p> ?o . filter (?g = <g1>) } \n";

sparql select * where { graph ?g { ?s <p> ?o . filter (?g in (<g1>, <g2>, <g3>)) }};
ECHO BOTH $IF $EQU $ROWCNT 3 "PASSED" "***FAILED";
ECHO BOTH ": 3 rows ?s <p> ?o . filter (?g in (<g1>, <g2>, <g3>)) \n";

explain('sparql select * where { graph ?g { ?s ?p ?o . filter (?s in (<s1>, <s2>, <s3>)) }}');
explain('sparql select * where { graph ?g { ?s ?p ?o . filter (?g in (<g1>, <g2>, <g3>)) }}');

sparql select * where { graph ?g { ?s ?p ?o . filter (?s in (<s1>, <s2>, <s3>)) }};
ECHO BOTH $IF $EQU $ROWCNT 6 "PASSED" "***FAILED";
ECHO BOTH ": 6 rows ?s in (<s1>, <s2>, <s3>) \n";

sparql select * where { graph ?g { ?s ?p ?o . filter (?g in (<g1>, <g2>, <g3>)) }};
ECHO BOTH $IF $EQU $ROWCNT 6 "PASSED" "***FAILED";
ECHO BOTH ": 6 rows ?g in (<g1>, <g2>, <g3>) \n";

select * from DB.DBA.RDF_QUAD table option (index RDF_QUAD) where g in ( __i2id ( UNAME'g3' ) , __i2id ( UNAME'g2' ) , __i2id ( UNAME'g1' ));
ECHO BOTH $IF $EQU $ROWCNT 6 "PASSED" "***FAILED";
ECHO BOTH ": 6 rows g in (g1, g2, g3) by PK \n";

select * from DB.DBA.RDF_QUAD table option (index RDF_QUAD) where s in ( __i2id ( UNAME's3' ) , __i2id ( UNAME's2' ) , __i2id ( UNAME's1' ));
ECHO BOTH $IF $EQU $ROWCNT 6 "PASSED" "***FAILED";
ECHO BOTH ": 6 rows s in (s1, s2, s3) by PK\n";


select * from DB.DBA.RDF_QUAD table option (index RDF_QUAD_GS) where g in ( __i2id ( UNAME'g3' ) , __i2id ( UNAME'g2' ) , __i2id ( UNAME'g1' ));
ECHO BOTH $IF $EQU $ROWCNT 6 "PASSED" "***FAILED";
ECHO BOTH ": 6 rows g in (g1, g2, g3) by GS\n";

select * from DB.DBA.RDF_QUAD table option (index RDF_QUAD_SP) where s in ( __i2id ( UNAME's3' ) , __i2id ( UNAME's2' ) , __i2id ( UNAME's1' ));
ECHO BOTH $IF $EQU $ROWCNT 6 "PASSED" "***FAILED";
ECHO BOTH ": 6 rows s in (s1, s2, s3) by SP\n";

explain('sparql select * where { graph ?g { ?s ?p ?o . filter (?o in (10,20,30)) }}');
sparql select * where { graph ?g { ?s ?p ?o . filter (?o in (10,20,30)) }};
explain ('select * from DB.DBA.RDF_QUAD table option (index RDF_QUAD) where o in (10,20,30)');
select * from DB.DBA.RDF_QUAD table option (index RDF_QUAD_OP) where o in (10,20,30);

explain ('delete from rdf_quad table option (index RDF_QUAD) where g in ( __i2id ( UNAME\'g3\' ) , __i2id ( UNAME\'g2\' ) , __i2id ( UNAME\'g1\' ))');
explain ('delete from rdf_quad table option (index RDF_QUAD_GS) where g in ( __i2id ( UNAME\'g3\' ) , __i2id ( UNAME\'g2\' ) , __i2id ( UNAME\'g1\' ))');
delete from rdf_quad table option (index RDF_QUAD_GS) where g in ( __i2id ( UNAME'g3' ) , __i2id ( UNAME'g2' ) );
select * from DB.DBA.RDF_QUAD table option (index RDF_QUAD) where s in ( __i2id ( UNAME's3' ) , __i2id ( UNAME's2' ) , __i2id ( UNAME's1' ));
ECHO BOTH $IF $EQU $ROWCNT 2 "PASSED" "***FAILED";
ECHO BOTH ": 2 rows s in (s1, s2, s3) by PK\n";


select * from DB.DBA.RDF_QUAD table option (index RDF_QUAD_GS) where g in ( __i2id ( UNAME'g3' ) , __i2id ( UNAME'g2' ) , __i2id ( UNAME'g1' ));
ECHO BOTH $IF $EQU $ROWCNT 2 "PASSED" "***FAILED";
ECHO BOTH ": 2 rows g in (g1, g2, g3) by GS\n";
