ui <- fluidPage(
  theme = bs_theme(
    version = 5,
    bg = "#FFF",
    fg = "#101010",
    primary = "#040345",
    secondary = "#040345",
    base_font = font_google("Nunito"),
    code_font = font_google("Nunito")
  ),
  navset_tab (
    nav_panel (
      title = "Most Visited Pages",
      page_sidebar(
        title = "Input Log File",
        sidebar = tagList(
                        textInput(
                             inputId = "serverlogpath",
                             label = "Path of the log file on the server",
                             value = "/home/kvv/ssd1/all_git/R_NGINX_Log_Analyzer/access.log",
                             placeholder = "Enter path"
                           ),
                        fileInput(
                          inputId = "uploaded_file",   
                          label = "Or upload your CSV file",
                          accept = c()           
                        ),
                        textInput(
                             inputId = "filter_ip1",
                             label = "Ip to exclude (XXX.XXX.XXX.XXX--XXX.XXX.XXX.XXX...)",
                             value = "",
                             placeholder = "Enter ips"
                           ),
                        selectInput(
                            inputId = "time_unit1",
                            label = "Time Unit :",
                            choices = c("h", "d", "w", "m", "y"),
                            selected = "h",
                            multiple = FALSE
                        ),
                        numericInput(
                          inputId = "last_n1",
                          label = "n",
                          value = 15,    
                          min = 1,      
                          step = 1      
                        )
                  ),
      value_box(
          title = NULL,
          value = withSpinner(plotlyOutput(outputId = "pie_chart"), 
                              type = 5, 
                              size = 1.5)
        )
      )
    ),
    nav_panel (
      title = "WebPages",
      page_sidebar(
        title = "Specific WebPages",
        sidebar = tagList(
                          textInput(
                            inputId = "webpages",
                            label = "RegEx Expression:",
                            value = "^/$",
                            placeholder = "Enter a regex like ^France$"
                          ),
                          textInput(
                             inputId = "filter_ip2",
                             label = "Ip to exclude (XXX.XXX.XXX.XXX--XXX.XXX.XXX.XXX...)",
                             value = "",
                             placeholder = "Enter ips"
                           ),
                          selectInput(
                              inputId = "time_unit2",
                              label = "Time Unit :",
                              choices = c("h", "d", "w", "m", "y"),
                              selected = NULL,
                              multiple = FALSE
                          ),
                          numericInput(
                            inputId = "last_n2",
                            label = "n",
                            value = 15,    
                            min = 1,      
                            step = 1      
                          )
                ),
        value_box(
          title = NULL,
          value = withSpinner(plotlyOutput(outputId = "graph"), 
                              type = 5, 
                              size = 1.5)
        )
      )
    )
  )
)

ui <- secure_app(ui)


