#' CEDA Status
#'
#' Tries to check the status of the CEDA Archive by making empty requests to
#' some of the endpoints, printing the status update from the CEDA website
#' (\code{ceda_url_status_json()}) and optionally will try to make a new access token
#' to the openDAP service if provided with a username and password.
#'
#' @param user optional CEDA username
#' @param pass optional CEDA password
#'
#' @author W. S. Drysdale
#'
#' @export

ceda_status = function(user = NULL, pass = NULL){

  # Try to get a dap token
  if(!is.null(user) & !is.null(pass)){
    token = ceda_token(user, pass, force = T, suppressError = T)

    if(the$access_token_response$status_code == 200){
      cli::cli_alert_success(
        paste0("Token request at ", lubridate::round_date(the$access_token_time_of_last_request, "1 sec"), " returned status 200: OK")
      )
    }else{
      cli::cli_alert_danger(
        paste0("Token request at ", lubridate::round_date(the$access_token_time_of_last_request, "1 sec"), " returned status ", the$access_token_response$status_code,": ", httr2::resp_status_desc(the$access_token_response))
      )
    }

  }else{
    cli::cli_alert_info("CEDA username and password required to test token service")
  }

  # Send Test Requests to Endpoints
  reqList = list(
    data = httr2::request(ceda_url()),
    dap = httr2::request(ceda_url_dap()),
    status = httr2::request(ceda_url_status_json())
  ) |>
    purrr::map(
      \(x) httr2::req_error(x, is_error = \(resp) FALSE)
    )

  respList  = purrr::map(
    reqList, httr2::req_perform
  )

  for(i in 1:length(respList)){
    if(respList[[i]]$status_code == 200){
      cli::cli_alert_success(
        paste0(respList[[i]]$request$url," returned status 200: OK")
      )
    }else{
      cli::cli_alert_danger(
        paste0(respList[[i]]$request$url," returned status ", respList[[i]]$status_code,": ", httr2::resp_status_desc(respList[[i]]))
      )
    }
  }

  # Did we get the status? If so print now

  if(respList$status$status_code == 200){
    format_ceda_status(respList$status)
  }

}

#' Format CEDA Status
#'
#' Formats the status.json for printing to console
#'
#' @param respStatus the httr2 response for the request to \code{ceda_url_status_json()}
#'
#' @author W. S. Drysdale

format_ceda_status = function(respStatus){

  body = respStatus |>
    httr2::resp_body_string() |>
    jsonlite::fromJSON() |> # this gives us a nicer format to work with than resp_body_json()
    tibble::tibble() |>
    dplyr::mutate(date = lubridate::ymd_hm(date, tz = "UTC"))

  current = body |>
    dplyr::filter(date <= lubridate::with_tz(Sys.time(), "UTC")) |>
    dplyr::select(-tidyselect::any_of("updates"))

  future = body |>
    dplyr::filter(date > lubridate::with_tz(Sys.time(), "UTC")) |>
    dplyr::select(-tidyselect::any_of("updates"))

  cli::cli_h1("Current Incidents")
  if(nrow(current) > 0){

    currentFormatted = current |>
      dplyr::arrange(date) |>
      dplyr::mutate(date = as.character(date)) |>
      dplyr::relocate(date) |>
      dplyr::mutate(
        status = dplyr::case_when(
          status == "down" ~ cli::bg_red("down"),
          status == "degraded" ~ cli::col_black(cli::bg_yellow("degraded")),
          status == "resolved" ~ cli::col_black(cli::bg_green("resolved")),
        )
      )

    cat(clitable::cli_table(currentFormatted), sep = "\n")

  }else{
    cli::cli_h2("No Current Incidents")
  }

  cli::cli_h1("Future Incidents")
  if(nrow(future) > 0){

    futureFormatted = future |>
      dplyr::arrange(date) |>
      dplyr::mutate(date = as.character(date)) |>
      dplyr::relocate(date) |>
      dplyr::mutate(
        status = dplyr::case_when(
          status == "down" ~ cli::bg_red("down"),
          status == "degraded" ~ cli::col_black(cli::bg_yellow("degraded")),
          status == "resolved" ~ cli::col_black(cli::bg_green("resolved")),
        )
      )

    cat(clitable::cli_table(futureFormatted), sep = "\n")

  }else{
    cli::cli_h2("No Future Incidents")
  }

  cli::cli_text(
    paste0("View details at the {.href [CEDA Status page](",ceda_url_status(),")}")
  )


}


