
library(shiny)
library(igraph)
library(sqldf)

shinyServer(
    function(input, output) {

        g = reactive({
            m <- erdos.renyi.game(input$size, input$probability)
            as.undirected(m, mode=c("collapse"), edge.attr.comb = list(weight=sum))
        })
        
              
        centrality = reactive({
            # get the node name
            cty_name <- c(1:input$size)
            
            # get the centralities
            cty_degree <- degree(g())
            cty_eigen <- evcent(g())$vector
            cty_closeness <- closeness(g())
            cty_between <- betweenness(g())
            cty_cluster_coeff <- transitivity(g(), type="local")
            
            # combine them together
            new_df_cty <- data.frame(cty_name,cty_degree,cty_eigen,cty_closeness,cty_between,cty_cluster_coeff)
            
            #define threshold for roles
            eign_threshold <- max(cty_eigen)/2
            btwn_threshold <- max(cty_between)/2 
            
            role_sql_string <- paste0("select cty_name as Node,cty_degree as Degree,cty_eigen as Eigenvector,cty_closeness as Closeness,cty_between as Betweenness,cty_cluster_coeff as ClusterCoefficient, case when  ( cty_eigen > ",eign_threshold," and cty_between > ",btwn_threshold," ) then 'LEADER' 
                                      when  (cty_eigen > ",eign_threshold," and cty_between < ",btwn_threshold,") then 'PULSE TAKER' 
                                      when  ( cty_eigen < ",eign_threshold," and cty_between > ",btwn_threshold," ) then 'GATEKEEPER' 
                                      else 'FOLLOWER' end Role from new_df_cty")
            sqldf(role_sql_string)
        })
        
        
        output$gplot = renderPlot({
            plot(g(),layout=layout.mds)
        })
        
        output$table <- renderDataTable({
            #centrality()
            data <- centrality()
        })
        
        output$roleplot = renderPlot({
            cty_name <- c(1:input$size)
            cty_eigen <- evcent(g())$vector
            cty_between <- betweenness(g())
            
            plot(cty_between, cty_eigen, xlab="Betweenness", ylab="Eigenvector")
            text(cty_between, cty_eigen, cty_name, cex=0.6, pos=4, col="red")
            abline(h=max(cty_eigen)/2,v=max(cty_between)/2)
        })
        
        
    }
)