shinyUI(
    pageWithSidebar(
        # Application title
        headerPanel("Social Network Exploration"),
        sidebarPanel(
            h5('This application allows the user to explore how roles can be inferred from a social network relationships.'),
            h5('Also provided are other centralities scores for each node generated. The network graph are also generated.'),
            h5('Graph are randomly generated based on Erdos-Renyi model.'),  
            h5('To start exploring, enter the network size and edge probability below.'), 
            
            numericInput('size', 'Network Size', 10, min = 5, max = 100, step = 5),
            h6('Network Size: Please enter a round number between 5 - 100'),
            
            numericInput('probability', 'Edge Probability', 0.3, min = 0, max = 1, step = 0.1),
            h6('Edge Probability: Please enter a value between 0 - 1'),
            submitButton('Submit')
        ),
        mainPanel(
            tabsetPanel(
                tabPanel('Network Graph', 
                         h5('Erdos-Renyi graph generated from the entered size parameter. Edge probability is fixed at 33%.'),
                         plotOutput("gplot")),
                tabPanel('Centrality Measurements',fluidRow(
                    dataTableOutput(outputId="table")
                )),
                tabPanel('Roles in Relationship', 
                         h5('An actor with very high betweenness but low EC may be a critical gatekeeper to a central actor. Likewise, an actor with low betweenness but high EC may have unique access to central actors - Drew Conway, Deparment of Politics, NYU'), 
                         plotOutput("roleplot"))
            )

        )
    )
)