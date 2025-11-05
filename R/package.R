#' Get the path to the stablehlo-opt binary
#' 
#' This function returns the path to the stablehlo-opt binary. If the binary
#' is not found and `install` is TRUE, it will attempt to download and install
#' the binary.
#' 
#' @param install Logical, whether to install the binary if not found. Default is TRUE.
#' @return The file path to the stablehlo-opt binary.
#' 
#' @export
stablehlopt_bin <- function(install = TRUE) {
  bin <- file.path(stablehlopt_home(), stablehlopt_bin_fname())
  if (!file.exists(bin) && install) {
    stablehlopt_install()
    return(stablehlopt(install = FALSE))
  }
  return(bin)
}

stablehlopt_home <- function() {
  if (Sys.getenv("STABLEHLOPT_HOME") != "") {
    return(Sys.getenv("STABLEHLOPT_HOME"))
  }

  system.file("bin", package = "stablehlopt")
}

stablehlopt_bin_fname <- function() {
  if (Sys.info()[["sysname"]] == "Windows") {
    "stablehlo-opt.exe"
  } else {
    "stablehlo-opt"
  }
}

stablehlopt_install <- function() {
  message("Installing stablehlo-opt...")
  url <- stablehlopt_url()

  tmp_dir <- withr::local_tempdir()
  
  destfile <- file.path(tmp_dir, "stablehlo-opt.tar.gz")
  download.file(url, destfile, mode = "wb")

  untar(destfile, exdir = tmp_dir)

  bin_src <- file.path(tmp_dir, stablehlopt_bin_fname())
  bin_path <- file.path(stablehlopt_home(), stablehlopt_bin_fname())
  file.copy(bin_src, bin_path, overwrite = TRUE)

  message("stablehlo-opt installed.")
}

stablehlopt_url <- function() {
  base_url <- Sys.getenv("STABLEHLOPT_BASE_URL", "https://github.com/r-xla/pjrt-builds/releases/download/stablehlo")
  version <- Sys.getenv("STABLEHLOPT_VERSION", "main")

  os <- tolower(Sys.info()[["sysname"]])
  if (os == "darwin") os <- "mac"

  arch <- Sys.info()[["machine"]]
  
  paste0(base_url, "/stablehlo-opt-", version, "-", tolower(os), "-", tolower(arch), ".tar.gz")
}
