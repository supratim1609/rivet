# Rivet Architecture

```mermaid
graph TD
    subgraph Client ["Flutter App (Client)"]
        UI[User Interface]
        State[State Management]
        API_Client[API Client]
    end

    subgraph Rivet ["Rivet Server (Backend)"]
        Router[Trie-Based Router]
        Middleware[Middleware Chain]
        
        subgraph Core ["Core Features"]
            Auth[JWT Auth]
            WS[WebSocket Manager]
            Admin[Admin Panel]
        end
        
        subgraph Data ["Data Layer"]
            ORM[Query Builder]
            Pool[Connection Pool]
        end
    end

    subgraph DB ["Database"]
        Postgres[(PostgreSQL)]
        Redis[(Redis / Cache)]
    end

    %% Connections
    UI --> State
    State --> API_Client
    API_Client -- "HTTP / WebSocket" --> Router
    
    Router --> Middleware
    Middleware --> Core
    
    Core --> Data
    Data -- "SQL" --> Postgres
    Data -- "Cache" --> Redis

    %% Styling
    style Client fill:#e3f2fd,stroke:#1565c0,stroke-width:2px
    style Rivet fill:#212121,stroke:#00e676,stroke-width:2px,color:#fff
    style DB fill:#fff3e0,stroke:#ef6c00,stroke-width:2px
```

## Key Components
1.  **Trie-Based Router:** O(path_length) matching for blazing speed.
2.  **Middleware Chain:** Global and route-specific processing (Auth, CORS, Logging).
3.  **Isolate Cluster:** Multi-core processing for high throughput.
4.  **Native Compilation:** AOT compiled binary for instant startup.
