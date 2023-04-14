package_dir <- paste0("~/R/", "r-packages-", R.Version()$major, ".", R.Version()$minor)

dir.create(package_dir, recursive = T, showWarnings = F)

.libPaths(new = package_dir)

if !(find.package("markdown", quiet = TRUE)) {
    install.packages("markdown", lib = package_dir)
}
