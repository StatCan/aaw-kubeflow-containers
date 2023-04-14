NB_USER <- Sys.getenv("NB_USER")

home_dir <- paste0("/home/", NB_USER)

package_dir <- paste0(home_dir, "/R/", "r-packages-", R.Version()$major, ".", R.Version()$minor)

dir.create(package_dir, recursive = T, showWarnings = F)

.libPaths(new = package_dir)

if !(find.package("markdown", quiet = TRUE)) {
    install.packages("markdown", lib = package_dir)
}
