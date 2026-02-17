# GO.db2 is an experimental package that partially emulates GO.db 

The [GO.db](https://bioconductor.org/packages/GO.db) package has a long
history as an outcome of the 
[BioconductorAnnotationPipeline](https://github.com/bioconductor/BioconductorAnnotationPipeline).  It works via the classes and methods of [AnnotationDbi](https://bioconductor.org/packages/AnnotationDbi).

AnnotationDbi defines a significant collection of database schemas with
the overall strategy depicted here, in a figure from an AnnotationDbi vignette.

<img src="https://raw.githubusercontent.com/vjcitn/GO.db2/fbf46341c64c1188cb0c0d082ccb3c7adce5ae42/man/figures/AnnoDbi.png" width="400px"/>

Many changes have occurred since the production of AnnotationDbi.

- The architects of the system have left Bioconductor.
- Some of the concepts targeted in the diagram aren't as significant to active users
as they once were (e.g., microarray annotations).
- Underlying resources being conveyed into the ecosystem have changed,
and access to some has been curtailed.

The Bioconductor project will leave GO.db in the state it had at 3.22.  Alternative approaches
to conveying Gene Ontology information for use in workflows will be explored in
a number of packages.  This is one example.

# Using GO.db2

## Installation

```
BiocManager::install("vjcitn/GO.db2") # be sure devtools and remotes are installed
```

## Examples

We do not use `select`.  We define `select2` as an ordinary function.

```
> library(GO.db2)
> select2("GO.db2", keys="GO:0009435", keytype="GOID", columns=c("GOID", "TERM", "ONTOLOGY"))
        GOID                      TERM ONTOLOGY
1 GO:0009435 NAD+ biosynthetic process       BP
```

We do not create environments like GOBPPARENTS in the package namespace.  Instead,
functions produce the environments.

```
> get("GO:0009435", GOBPPARENTS())
        is_a         is_a         is_a 
"GO:0006164" "GO:0019359" "GO:0019674" 
```

We have not, at this point, recreated all the interfaces to GO that were
available in GO.db.  Issues should be filed about missing elements.

## Details

A sqlite database underlies this package.  It was created using
the tooling at [BiocGOPrep](https://github.com/vjcitn/BiocGOPrep).

```
>     con = dbConnect(SQLite(), system.file("extdata", "go-basic.sqlite3", 
+         package = "GO.db2"), flags = SQLITE_RO)
> 
> dbListTables(con)
 [1] "go_bp_offspring" "go_bp_parents"   "go_cc_offspring" "go_cc_parents"  
 [5] "go_mf_offspring" "go_mf_parents"   "go_obsolete"     "go_ontology"    
 [9] "go_synonym"      "go_term"         "map_counts"      "map_metadata"   
[13] "metadata"       
```
