#各種関数を定義したコードを読む。
source("forecasts.R")

#本体
server <- function(input, output, session) {
  observeEvent(input$file, {
    
    #データ読み込み
    csv_file <- reactive(read.csv(input$file$datapath))
    
    #Tableタブに読み込み
    output$table <- renderTable(head(csv_file(), n = 30))
    
    #日付の列を指定
    output$ds <- renderUI({ 
      selectInput("ds", "Date", colnames(csv_file()))
    })
    
    #数値の列を指定
    output$y <- renderUI({ 
      selectInput("y", "y", colnames(csv_file()))
    })
    
    #予測期間を指定
    output$periods <- renderUI({ 
      numericInput("periods", label = "Periods",value = 365)
    })
    
    #frequencyを指定
    output$freq <- renderUI({ 
      selectInput("freq", "Frequency", 
                  c("day", "week", "month", "quarter", "year",1, 60, 3600))
    })

  })
  
  #submitを押した後の動作, 
  observeEvent(input$submit, {
    #ファイルを読み込み
    csv_file <- reactive({read.csv(input$file$datapath)})
    
    #prophetに読み込ませるデータを成形
    df <- reactive({make.df(ds = csv_file()[input$ds], y = csv_file()[input$y])})
    
    #prophet本体
    result <- reactive({prophet(df())})
    
    #予測
    forecast <- reactive({
      forecast.pred(result(), periods = input$periods, freq = input$freq)
      })
    
    #結果のプロット
    output$plot <- renderPlot({plot(result(), forecast())})
    
    #未来の値の表示
    output$sum <- renderTable({forecast_ds(forecast())})
    
  })
}



