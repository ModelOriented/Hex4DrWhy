library(ggplot2)
library(shiny)

h = sqrt(3)/2

# generate coordinates for triangle in a given row and col
get_triangle_coords <- function(row = 1, col = 1, id = 1) {
    if (col %% 2 == 0) {
        x <- c(0, 1, 0)
        y <- col %/% 2 + c(0, 1/2, 1)
    } else {
        x <- c(1, 0, 1)
        y <- col %/% 2 + c(1/2, 1, 3/2)
    }
    if (row %% 2 == 0) {
        x <- 1 - x
    }
    x <- h*x + h*row
    data.frame(x, y, id = id)
}

# get coords
tmp1 <- sapply(1:9, function(i) {
    get_triangle_coords(1, i, id = i)
}, simplify = FALSE)
df1 <- do.call(rbind, tmp1)

tmp2 <- sapply(1:9, function(i) {
    get_triangle_coords(2, i, id = 9+i)
}, simplify = FALSE)
df2 <- do.call(rbind, tmp2)

tmp3 <- sapply(1:9, function(i) {
    get_triangle_coords(3, i-2, id = 18+i)
}, simplify = FALSE)
df3 <- do.call(rbind, tmp3)

tmp4 <- sapply(1:9, function(i) {
    get_triangle_coords(4, i-2, id = 27+i)
}, simplify = FALSE)
df4 <- do.call(rbind, tmp4)

tmp5 <- sapply(6:9, function(i) {
    get_triangle_coords(5, i-4, id = 36+i-5)
}, simplify = FALSE)
df5 <- do.call(rbind, tmp5)

tmp6 <- sapply(7:9, function(i) {
    get_triangle_coords(6, i-4, id = 40+i-6)
}, simplify = FALSE)
df6 <- do.call(rbind, tmp6)

df <- rbind(df1, df2, df3, df4, df5, df6)

ind <- c(0,0,0,0,0,0,0,0,1,
         1,1,0,0,1,1,1,1,1,
         0,0,0,0,0,0,0,0,1,
         1,1,0,0,1,1,1,1,1,
         0,0,0,1,1,1,1)

df_red <- df[df$id %in% which(ind == 1),]
df_blue <- df[df$id %in% which(ind == 0),]

df_fiolet <- rbind(get_triangle_coords(-2, -3, id = -1)[3,],
                   get_triangle_coords(-2, 9, id = -1)[1,],
                   get_triangle_coords(3, 13, id = -1)[3,],
                   get_triangle_coords(9, 9, id = -1)[1,],
                   get_triangle_coords(9, -3, id = -1)[3,],
                   get_triangle_coords(3, -7, id = -1)[1,])


# Define server logic required to draw a histogram
shinyServer(function(input, output) {

    get_plot <- reactive({
        pname <- input$library_name
        ind <- strsplit(input$bit_hex, split = "[^01]")[[1]]

        df_red <- df[df$id %in% which(ind == "1"),]
        df_blue <- df[df$id %in% which(ind == "0"),]

        main_color <- switch (input$hex_type,
                              general = "#8bdcbe",
                              explanations = "#ffa58c",
                              automation = "#46bac2"
        )
        secondary_color <- switch (input$hex_type,
                                   general = "#4378bf",
                                   explanations = "#ae2c87",
                                   automation = "#371ea3"
        )

        if (input$hex_background == "website") {
            # website, white background
            b_color = "white"
            s_color = secondary_color
            p_color = main_color
            o_color = main_color
        } else {
            # hex, with background
            b_color = main_color
            s_color = secondary_color
            p_color = "white"
            o_color = main_color
        }

        ggplot(df) +
            geom_polygon(data=df_fiolet, aes(x = x-h/2, y = y, group = id), fill = b_color, color = o_color, size=3.5) +
            geom_polygon(data=df_red, aes(x = x, y = y, group = id), fill = s_color) +
            geom_polygon(data=df_blue, aes(x = x, y = y, group = id), fill = p_color) +
            geom_text(x=5, y=-1, label = pname, angle = 30, size=11, color=s_color, family = "sans")+
            coord_fixed() + theme_void() + theme(legend.position = "none")
    })

    output$distPlot <- renderPlot({
        get_plot()
    })

    output$download_png <- downloadHandler(
        filename = function() {
            paste('drwhy_', input$library_name, '_',input$hex_background,'.png', sep='')
        },
        content = function(con) {
            plt <- get_plot()
            png(con, width = 360, height = 360)
            print(plt)
            dev.off()
        }
    )

    output$download_pdf <- downloadHandler(
        filename = function() {
            paste('drwhy_', input$library_name, '_',input$hex_background,'.pdf', sep='')
        },
        content = function(con) {
            plt <- get_plot()
            pdf(con, width = 5, height = 5)
            print(plt)
            dev.off()
        }
    )

})
