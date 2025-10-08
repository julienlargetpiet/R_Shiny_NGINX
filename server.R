function (input, output, session) {

  res_auth <- secure_server(
    check_credentials = check_credentials(credentials)
  )

  #filter_ip <- reactiveVal("")

  #observeEvent(input$filter_ip1, ignoreInit = TRUE, {
  #  updateTextInput(session, "filter_ip2", value = input$filter_ip1)
  #  filter_ip(input$filter_ip1)
  #})

  #observeEvent(input$filter_ip2, ignoreInit = TRUE, {
  #  updateTextInput(session, "filter_ip1", value = input$filter_ip2)
  #  filter_ip(input$filter_ip2)
  #})

  last_n <- reactiveVal(15)      

  observeEvent(input$last_n1, ignoreInit = TRUE, {
    updateNumericInput(session, "last_n2", value = input$last_n1)
    last_n(input$last_n1)
  })

  observeEvent(input$last_n2, ignoreInit = TRUE, {
    updateNumericInput(session, "last_n1", value = input$last_n2)
    last_n(input$last_n2)
  })

  time_unit <- reactiveVal("h")      

  observeEvent(input$time_unit1, ignoreInit = TRUE, {
    updateSelectInput(session, "time_unit2", selected = input$time_unit1)
    time_unit(input$time_unit1)
  })

  observeEvent(input$time_unit2, ignoreInit = TRUE, {
    updateSelectInput(session, "time_unit1", selected = input$time_unit2)
    time_unit(input$time_unit2)
  })

  filtered_data <- reactive({

    if (!is.null(input$uploaded_file)) {
      file_path <- input$uploaded_file$datapath
    } else if (!is.null(input$serverlogpath) && input$serverlogpath != "") {
      file_path <- input$serverlogpath
    } else {
      req(FALSE, "No file available yet.")
    }

    df <- read_delim(
      file_path,
      delim = " ",
      quote = '"',
      col_names = FALSE,
      trim_ws = TRUE,
      col_types = cols(
        .default = col_character(),
        X7 = col_double(),
        X8 = col_double()
      )
    )

    #excluded_ips <- strsplit(filter_ip(), "--")[[1]]

    df <- df %>%
      filter(!grepl(bot_pat, .[[10]]))

    df <- df[, c(1, 4, 6)]
    names(df) <- c("ip",
                  "date",
                  "target")

    #df <- df[!df$ip %in% excluded_ips, ]
    df$date <- as.POSIXct(substring(df$date, 2), format="%d/%b/%Y:%H:%M:%S") 

    start <- as.POSIXct("01/Sep/1970:00", format="%d/%b/%Y:%H")
    end <- as.POSIXct("01/Sep/2970:00", format="%d/%b/%Y:%H")
    last <- last_n() * mult_map[[time_unit()]]
    df <- df[df$date >= (max(df$date) - last), ]


    df$target <- mapply(function(x) { 
                            posvec <- gregexpr(" ", x)[[1]][1:2]
                            substring(x, posvec[1] + 1, posvec[2] - 1)}, 
                            df$target)

    df

  })

  output$graph <- renderPlotly({
    df <- filtered_data()
    if (!is.null(input$webpages) && nzchar(input$webpages)) {
      patterns <- strsplit(input$webpages, "--")[[1]]
      df <- df[Reduce(`|`, lapply(patterns, function(p) grepl(p, df$target))), ]
      df$target_group <- df$target
      for (ptrn in patterns) {
        df$target_group <- ifelse(grepl(ptrn, df$target_group), ptrn, df$target_group)
      }
    } else {
      df$target_group <- df$target
    }

    req(nrow(df) > 0)

    interval <- interval_map[[time_unit()]]
    df$date <- floor_date(df$date, unit = interval)
    df <- df %>%
      group_by(target_group, date) %>%
      summarise(hits = n(), .groups = "drop")

    plot_ly(
      data = df,
      x = ~date,
      y = ~hits,
      color = ~target_group,
      type = "scatter",
      mode = "lines+markers"
    ) %>%
      layout(
        title = "Traffic by URL",
        xaxis = list(title = "Date"),
        yaxis = list(title = "Number of requests"),
        legend = list(orientation = "h", x = 0.4, y = -0.2)
      )
  })
  
  #output$graph <- renderPlotly({ # ggplot2 -> plotly

  #    if (!is.null(input$webpages) && nzchar(input$webpages)) {

  #      patterns <- strsplit(input$webpages, "--")[[1]]
  #      
  #      df <- filtered_data()

  #      df <- df[Reduce(`|`, lapply(patterns, function(p) 
  #                                               grepl(p, df$target))), ]
  #      
  #      df$target_group <- df$target
  #      for (ptrn in patterns) {
  #        df$target_group <- ifelse(grepl(ptrn, df$target_group),
  #                                  ptrn,
  #                                  df$target_group)
  #      }
  #    } else {
  #      df$target_group = df$target
  #    }

  #    req(nrow(df) > 0)

  #    interval <- interval_map[[time_unit()]]
  #    df$date <- floor_date(df$date, unit = interval)

  #    df <- df %>%
  #      group_by(target_group, date) %>%
  #      summarise(hits = n(), .groups = "drop")
 
  #    p <- ggplot(df, aes(x = date, y = hits, color = target_group)) +
  #      geom_line() +
  #      geom_point() +
  #      labs(x = "Date",
  #           y = "Number of requests",
  #           title = "Traffic by URL") +
  #      theme_minimal() 

  #    ggplotly(p)

  #  })

    output$pie_chart <- renderPlotly({
      df <- filtered_data()
      req(nrow(df) > 0)
    
      agg <- df %>%
        group_by(target) %>%
        summarise(hits = n(), .groups = "drop") %>%
        arrange(desc(hits)) %>%
        head(5)
    
      total_hits <- sum(agg$hits)
    
      plot_ly(
        data = agg,
        labels = ~target,
        values = ~hits,
        type = 'pie',
        textinfo = 'label+percent',
        insidetextorientation = 'radial'
      ) %>%
        layout(
          title = paste("Most visited targets —", total_hits, "total hits!"),
          showlegend = TRUE
        )
    })

  output$mytable <- renderDataTable({filtered_data()})

  #output$pie_chart <- renderPlotly({ #ggplot2 -> plotly

  #   df <- filtered_data()

  #   req(nrow(df) > 0)

  #    agg <- df %>%
  #        group_by(target) %>%
  #        summarise(hits = n(), .groups = "drop") %>%
  #        arrange(desc(hits)) %>%
  #        head(5)
  #    
  #    total_hits <- sum(agg$hits)
  #    
  #    p <- ggplot(agg, aes(x = "", y = hits, fill = target)) +
  #      geom_bar(stat = "identity", width = 1) +
  #      coord_polar(theta = "y") +
  #      theme_void() +
  #      labs(
  #        title = paste("Most visited targets, a total of", 
  #                      total_hits, 
  #                      "total hits!"),
  #        fill = "Target Group"
  #      ) +
  #      geom_text(
  #        aes(label = paste0(round(100 * hits / sum(hits), 1), "%")),
  #        position = position_stack(vjust = 0.5)
  #      )

  #      ggplotly(p)
  #  })

}





