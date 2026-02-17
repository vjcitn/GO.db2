# GO.db2 is an experimental package that partially emulates GO.db 

The [GO.db](https://bioconductor.org/packages/GO.db) package has a long
history as an outcome of the 
[BioconductorAnnotationPipeline](https://github.com/bioconductor/BioconductorAnnotationPipeline).  It works via the classes and methods of [AnnotationDbi](https://bioconductor.org/packages/AnnotationDbi).

AnnotationDbi defines a significant collection of database schemas with
the overall strategy depicted here, in a figure from an AnnotationDbi vignette.

![](man/figures/AnnoDbi.png)

Many changes have occurred since the production of AnnotationDbi.

- The architects of the system have left Bioconductor.
- Some of the concepts targeted in the diagram aren't as significant to active users
as they once were (e.g., microarray annotations).
- Underlying resources being conveyed into the ecosystem have changed,
and access to some has been curtailed.
