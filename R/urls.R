#' CEDA URL
#' Returns the root URL for the CEDA data repository
#'
#' @export

ceda_url = function(){
  "https://data.ceda.ac.uk"
}

#' CEDA URL openDAP
#' Returns the root URL for the CEDA openDAP service
#'
#' @export

ceda_url_dap = function(){
  "https://dap.ceda.ac.uk"
}

#' CEDA URL Token
#'
#' returns the URL for refreshing CEDA acccess tokens
#' @export

ceda_url_token = function(){
  "https://services-beta.ceda.ac.uk/api/token/create/"
}

#' CEDA Status json
#'
#' returns the URL for the status.json page
#' @export

ceda_url_status_json = function(){
  "https://cedadev.github.io/ceda-status/status.json"
}

#' CEDA Status
#'
#' returns the URL for the status.json page
#' @export

ceda_url_status = function(){
  "https://www.ceda.ac.uk/status/"
}
