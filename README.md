# **Rick and Morty Characters App**

This app demonstrates modern iOS development practices for browsing characters and viewing their details. It uses **MVVM-C (Model-View-ViewModel-Coordinator)** architecture for a clean, modular, and scalable design.

---

## **Architecture Overview**

The app architecture follows the **MVVM-C pattern**, dividing responsibilities into:

1. **Model**: Represents the data layer (e.g., character information fetched from an API or local storage).
2. **ViewModel**: Handles business logic and binds data to the views using Combine.
3. **View**: Displays the user interface. Uses a mix of `UIKit` and `SwiftUI` for flexibility.
4. **Coordinator**: Manages navigation logic, separating it from the view controllers.

---

### **Components**

#### **1. Architecture: MVVM-C**

- **Model**:
  - Encapsulates character data.
  - Defines properties such as `name`, `subtitle`, and `imageURL`.

- **View**:
  - **UIKit**: Used for `CharacterListVC` view controller.
  - **SwiftUI**: Used for `CharacterDetailsView` to showcase modern UI components.
  - Provides reactive updates from the ViewModel.

- **ViewModel**:
  - Acts as the bridge between the view and model.
  - Handles logic for fetching and processing data.
  - Utilizes Combine's `@Published` properties to bind data to the view reactively.

- **Coordinator**:
  - **CharactersFlowCoordinator**:
    - Handles navigation between the character list and details view.
    - Implements the `CharactersListCoordinatorProtocol` and `CharacterDetailsCoordinatorProtocol` to decouple navigation logic from view controllers.
---

#### **2. Frameworks Used**

- **UI Frameworks**: 
  - **UIKit**: For navigation and table/collection views.
  - **SwiftUI**: For reusable, declarative components like the error view and character details view.

- **Binding Framework**:
  - **Combine**:
    - Binds the ViewModel's `@Published` properties to the views.
    - Observes loading states, data updates, and error handling reactively.

- **Testing Framework**:
  - **Swift Testing**:
    - Used for writing unit tests for ViewModel logic and ensuring ViewModel-to-View data flow is working correctly.
    - Tests include pagination logic, error handling, and Combine-based bindings.
---

# Network Layer Overview

## Core Components

### 1. Request Protocol (`RequestProtocol.swift`)
- Defines a contract for API requests with:
  - **Properties**:
    - `path`: The API endpoint path.
    - `requestType`: The HTTP method (e.g., GET, POST).
    - `headers`: Custom headers for the request.
    - `params`: Parameters for the request body.
    - `urlParams`: URL query parameters.
  - **Functionality**:
    - Provides a default implementation to create `URLRequest` objects.
    - Handles URL encoding, headers, and body configuration.

### 2. API Manager (`APIManager.swift`)
- Handles the execution of API requests using `URLSession`.
- **Features**:
  - Asynchronous request execution.
  - Validates HTTP status codes (2xx) and ensures non-empty data.
  - Returns a `Result` with either raw `Data` or a `NetworkError`.

### 3. Request Manager (`RequestManagerProtocol.swift`)
- Orchestrates interactions between `APIManager` and `DataParser`.
- **Responsibilities**:
  - Performs requests and validates responses.
  - Parses data into `Decodable` models.
  - Returns a `Result` containing either the parsed object or a `RequestError`.

### 4. Data Parser (`DataParserProtocol.swift`)
- Decodes raw `Data` into `Decodable` objects.
- **Features**:
  - Uses `JSONDecoder` with customizable strategies (e.g., snake_case conversion).
  - Handles decoding errors and returns either a parsed model or a `ParsingError`.

---

## Error Handling

### 1. Network Errors (`NetworkError.swift`)
- Enumerates potential network issues:
  - Invalid URL.
  - Unexpected status codes.
  - No data or no internet connection.
- Provides localized error descriptions for user-friendly feedback.

### 2. Request Errors (`RequestError.swift`)
- Wraps `NetworkError` and `ParsingError` into a unified interface.

### 3. Parsing Errors (`ParsingError.swift`)
- Represents JSON decoding issues with underlying error details.

---

## Extensibility and Testability

- **Protocols**:
  - `RequestProtocol`, `APIManagerProtocol`, and `DataParserProtocol` ensure flexibility and dependency injection.
- **Default Implementations**:
  - Simplify client code while allowing customization.
- **Error Types**:
  - Provide detailed diagnostics for debugging and user feedback.

---

## Data Flow Overview

1. **Request Construction**:
   - A `RequestProtocol` instance specifies the API endpoint, request type, parameters, and headers.
2. **Network Call**:
   - `APIManager` executes the request and validates the response.
3. **Data Parsing**:
   - `RequestManager` sends raw data to `DataParser` for decoding into the expected model.
4. **Error Propagation**:
   - Errors are encapsulated in `RequestError` and passed to the caller.

---

### **Instructions to Build and Run**

#### **Requirements**
- **Xcode**: 16.1 or later
- **iOS Deployment Target**: 18.1 or later

#### **Steps**
1. Open Terminal
2. Clone the repository:
   ```bash
   git clone https://github.com/OmarHegazy93/Rickipedia
   ```
3. Open repo folder:
```bash
   cd Rickipedia/Rickipedia
``` 
4. Open Rickipedia.xcodeproj
