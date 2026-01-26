#' Download File from CEDA
#'
#' Downloads a file from CEDA and saves it at fileOut
#'
#' @param url Download URL for file (should begin with https://dap.ceda.ac.uk)
#' @param user CEDA username
#' @param pass CEDA password
#' @param fileOut path to save file
#' @param isBinary Defaults to NULL, but can be set TRUE/FALSE to override
#'                 \code{resp_is_body_binary()}'s determination of whether the
#'                 downloaded file is binary or not
#'
#' @author W. S. Drysdale
#'
#' @export

ceda_download = function(url, fileOut, user, pass, isBinary = NULL){

  req = httr2::request(url) |>
    httr2::req_auth_bearer_token(
      token = ceda_token(user, pass)
    ) |>
    httr2::req_progress(type = "down")

  fileNameGuess = tryCatch({
    url |>
      basename() |>
      stringr::str_remove("\\?download=1")
  },
  error = function(e){
    "File"
  }
  )

  cli::cli_alert(paste0("Downloading: ",fileNameGuess))

  temp = httr2::req_perform(req)

  if(is.null(isBinary)){

    isBinary = resp_is_body_binary(temp)

  }

  if(isBinary){
    writeBin(httr2::resp_body_raw(temp), fileOut)
  }else{
    writeLines(httr2::resp_body_string(temp), fileOut)
  }

}

#' Is Response Body Binary
#'
#' Heuristic test to determine if the body of a response from httr2 contains a
#' binary file. Adapted from code in [knitrdata](https://github.com/dmkaplan2000/knitrdata/blob/master/R/utils.R)
#' to work with httr2 response
#'
#' @param resp httr2 response from \code{httr2::req_perform}
#' @param bin.ints ASCII control character values that indicate a binary file
#' @param nbytes number of bytes used from the begining of the body
#' @param nbin threshold for number of control characters found for file to be
#'             considered binary. (Default 2)
#'
#' @export

resp_is_body_binary = function(
    resp,
    bin.ints = c(1:8,14:25),
    nbytes = 1000,
    nbin = 2){

  if(!httr2::resp_has_body(resp)){
    stop("Response object has no body")
  }

  x = as.integer(resp$body)[1:nbytes]
  n = sum(x %in% bin.ints)

  n>nbin # TRUE if file is binary

}
