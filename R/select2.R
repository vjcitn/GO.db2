#> GO.db
#GODb object:
#| GOSOURCENAME: Gene Ontology
#| GOSOURCEURL: http://current.geneontology.org/ontology/go-basic.obo
#| GOSOURCEDATE: 2025-07-22
#| Db type: GODb
#| package: AnnotationDbi
#| DBSCHEMA: GO_DB
#| GOEGSOURCEDATE: 2025-Sep24
#| GOEGSOURCENAME: Entrez Gene
#| GOEGSOURCEURL: ftp://ftp.ncbi.nlm.nih.gov/gene/DATA
#| DBSCHEMAVERSION: 2.1
#
#Please see: help('select') for usage information
#> search()
# [1] ".GlobalEnv"            "package:GO.db"         "package:AnnotationDbi"
# [4] "package:IRanges"       "package:S4Vectors"     "package:Biobase"      
# [7] "package:BiocGenerics"  "package:generics"      "package:stats4"       
#[10] "package:RSQLite"       "package:stats"         "package:graphics"     
#[13] "package:grDevices"     "package:utils"         "package:datasets"     
#[16] "package:devtools"      "package:usethis"       "package:rmarkdown"    
#[19] "package:methods"       "Autoloads"             "package:base"         
#> ls(2)
# [1] "GO"            "GO_dbconn"     "GO_dbfile"     "GO_dbInfo"    
# [5] "GO_dbschema"   "GO.db"         "GOBPANCESTOR"  "GOBPCHILDREN" 
# [9] "GOBPOFFSPRING" "GOBPPARENTS"   "GOCCANCESTOR"  "GOCCCHILDREN" 
#[13] "GOCCOFFSPRING" "GOCCPARENTS"   "GOMAPCOUNTS"   "GOMFANCESTOR" 
#[17] "GOMFCHILDREN"  "GOMFOFFSPRING" "GOMFPARENTS"   "GOOBSOLETE"   
#[21] "GOSYNONYM"     "GOTERM"    

#> dbListTables(con)
# [1] "go_bp_offspring" "go_bp_parents"   "go_cc_offspring" "go_cc_parents"  
# [5] "go_mf_offspring" "go_mf_parents"   "go_obsolete"     "go_ontology"    
# [9] "go_synonym"      "go_term"         "map_counts"      "map_metadata"   
#[13] "metadata" 

#' superficial emulator of AnnotationDbi::select for Gene Ontology
#' @import DBI
#' @import dplyr
#' @import RSQLite
#' @param x character, must be "GO.db2"
#' @param keys for filtering, if NULL, no filtering performed
#' @param columns for joining and selecting
#' @param keytype for table selection: one of "term", "goid"; all caps may be used
#' @return data.frame
#' @note GO.db permitted columns and keytypes "DEFINITION", "GOID", "ONTOLOGY", "TERM"  
#' @examples
#' select2("GO.db2", keys="low-affinity zinc ion transmembrane transporter activity", keytype="term")
#' select2("GO.db2", keys="GO:0009435", keytype="GOID") |> dplyr::select(-definition)
#' select2("GO.db2", keys="GO:0009435", keytype="goid", columns=c("GOID", "TERM", "ONTOLOGY"))
#' @export
select2 = function(x, keys, columns=NULL, keytype, ...) {
 keytype=tolower(keytype)
 stopifnot(keytype %in% c("term", "goid"))
 stopifnot(length(keytype)==1)
 pname = packageName()
 stopifnot(x == pname)
 con = dbConnect(SQLite(), system.file("extdata", "go-basic.sqlite3", package="GO.db2"), flags=SQLITE_RO)
 on.exit(dbDisconnect(con))
 thetab = tbl(con, "go_term")
 if (keytype == "term") {
   if (!is.null(keys)) thetab = thetab |> dplyr::filter(term %in% keys) 
   }
 else if (keytype == "goid") {
   if (!is.null(keys)) thetab = thetab |> dplyr::filter(go_id %in% keys)
   }
 if (!is.null(columns)) {  # legacy
    if ("GOID" %in% columns) thetab = mutate(thetab, GOID=go_id)
    if ("TERM" %in% columns) thetab = mutate(thetab, TERM=term)
    if ("ONTOLOGY" %in% columns) thetab = mutate(thetab, ONTOLOGY=ontology)
    if ("DEFINITION" %in% columns) thetab = mutate(thetab, DEFINITION=definition)
    thetab = thetab |> as.data.frame()
    return(thetab[,columns])
    }
 thetab |> as.data.frame()
}

#' emulate the GO.db environments, but as functions: GOBP
#' @return environment mapping from GOID to parents in BP ontology
#' @export
GOBPPARENTS = function() {
 con = dbConnect(SQLite(), system.file("extdata", "go-basic.sqlite3", package="GO.db2"), flags=SQLITE_RO)
 thetab = tbl(con, "go_bp_parents") |> as.data.frame()
 ans = new.env()
 pars = thetab$parent_id
 names(pars) = thetab$relationship_type
 ids = thetab$go_id
 spar = split(pars, ids)
 nids = names(spar)
 for (i in seq_len(length(nids))) assign(nids[i], spar[[i]], ans)
 ans
}

#' emulate the GO.db environments, but as functions: GOMF
#' @return environment mapping from GOID to parents in MF ontology
#' @export
GOMFPARENTS = function() {
 con = dbConnect(SQLite(), system.file("extdata", "go-basic.sqlite3", package="GO.db2"), flags=SQLITE_RO)
 thetab = tbl(con, "go_mf_parents") |> as.data.frame()
 ans = new.env()
 pars = thetab$parent_id
 names(pars) = thetab$relationship_type
 ids = thetab$go_id
 spar = split(pars, ids)
 nids = names(spar)
 for (i in seq_len(length(nids))) assign(nids[i], spar[[i]], ans)
 ans
}

#' emulate the GO.db environments, but as functions: GOSYNONYM
#' @return environment mapping from GOID to synonyms
#' @examples
#' head(unname(GOSYNONYM()[["GO:0009435"]]))
#' # this could be better
#' tmpcon = dbConnect(SQLite(), system.file("extdata", "go-basic.sqlite3", package="GO.db2"), flags=SQLITE_RO)
#' tbl(tmpcon, "go_synonym") |> dplyr::filter(go_id == "GO:0009435")
#' DBI::dbDisconnect(tmpcon)
#' @export
GOSYNONYM = function() {
 con = dbConnect(SQLite(), system.file("extdata", "go-basic.sqlite3", package="GO.db2"), flags=SQLITE_RO)
 thetab = tbl(con, "go_synonym") |> as.data.frame()
 ans = new.env()
 syns = thetab$synonym
 names(syns) = thetab$scope
 ids = thetab$go_id
 ssyn = split(syns, ids)
 nids = names(ssyn)
 for (i in seq_len(length(nids))) assign(nids[i], ssyn[[i]], ans)
 ans
}
 

#compEpiTools:NAMESPACE: [ ]
#: importFrom(GO.db, GOCCPARENTS, GOBPPARENTS, GOMFPARENTS, GOTERM)
#goSTAG:NAMESPACE: [ ]
#: importFrom( "GO.db", "GOBPPARENTS", "GOCCPARENTS", "GOMFPARENTS", "GOTERM" )
#SemDist:R/utilities.R: [ ] language R
#:                       MF = "GOMFPARENTS",
#AnnotationDbi:R/GOTerms.R: [ ] language R
#:                  "mf"= toTable(GO.db::GOMFPARENTS),
#GOSemSim:NAMESPACE: [ ]
#: importFrom(GO.db,GOMFPARENTS)
#MetMashR:R/go_database_class.R: [ ] language R
#:                 "GOMFANCESTOR", "GOMFPARENTS",
#annotate:R/GOhelpers.R: [ ] language R
#:      MF_parents <- mget(x, envir=GO.db::GOMFPARENTS, ifnotfound=NA)
#:                     MF="GOMFPARENTS",



#CNEr:R/GO.R: [ ] language R
#:     ANCESTOR <- GOMFANCESTOR
#:     ANCESTOR = GOMFANCESTOR
#:   goID2Ancestor <- c(as.list(GOBPANCESTOR), as.list(GOMFANCESTOR), 
#AnnotationForge:R/NCBI_getters.R: [ ] language R
#:     mf_all <- .expandGOFrame(mf, GO.db::GOMFANCESTOR)
#ViSEAGO:NAMESPACE: [ ]
#: importFrom(GO.db,GOMFANCESTOR)
#AnnotationForge:R/makeOrgPackage.R: [ ] language R
#:     mfAll <- .expandGOFrame(gmf, GO.db::GOMFANCESTOR)
#SemDist:R/utilities.R: [ ] language R
#:                       MF = "GOMFANCESTOR",
#CNEr:NAMESPACE: [ ]
#:                   GOMFANCESTOR, GOMFOFFSPRING, GOMFCHILDREN)
#clusterProfiler:R/gson.R: [ ] language R
#:       if (ont_type == "MF") return(AnnotationDbi::mget(goids, GO.db::GOMFANCESTOR, ifnotfound=NA))
#AnnotationForge:R/makeOrgPackageFromNCBI.R: [ ] language R
##:     mf_all <- .expandGOFrame(mf, GO.db::GOMFANCESTOR)
