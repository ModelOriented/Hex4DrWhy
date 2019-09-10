library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(

    # Application title
    titlePanel("Hex4DrWhy"),

    # Sidebar with a slider input for number of bins
    sidebarLayout(
        sidebarPanel(
            textInput("library_name", label = "Package name", value = "DrWhy.AI", width = "200px"),
            selectInput("hex_background", "Version", c("website", "hex"), "website", width = "200px"),
            selectInput("hex_type", "Package type", c("original colors" = "original", "adapters (DALEX, DALEXtra)" = "adapters",
                                                      "explanations (ingredients, auditor, ...)" = "explanations", "automation (dime, modelDown, ...)" = "automation"),
                        "original", width = "200px"),
            textAreaInput("bit_hex", "Here put the binary pattern.\n Keep same number of digits.", "0 0 0 0 0 0 0 0 1
1 1 0 0 1 1 1 1 1
0 0 0 0 0 0 0 0 1
1 1 0 0 1 1 1 1 1
0 0 0 1 1 1 1", width = "200px", height = "150px")
        , width=3),

        # Show a plot of the generated distribution
        mainPanel(
            downloadLink("download_pdf", "[Download pdf]"),
            downloadLink("download_png", "[Download png]"),
            plotOutput("distPlot", width = "400px", height = "400px")
        )
    )
))
