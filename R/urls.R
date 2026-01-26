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
