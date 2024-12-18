import XCTest

final class Image_FeedUITests: XCTestCase {
    private let app = XCUIApplication() // переменная приложения
    
    override func setUpWithError() throws {
        continueAfterFailure = false // настройка выполнения тестов, которая прекратит выполнения тестов, если в тесте что-то пошло не так
        
        app.launch()
    }
    
     func testAuth() throws {
        // Нажимаем кнопку "Authenticate"
        app.buttons["LoginButton"].tap()
        
        // Ожидаем, пока откроется WebView
        let webView = app.webViews["UnsplashWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 5))
        
        // Проверяем наличие поля ввода для логина (email)
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        
        // Вводим e-mail
        loginTextField.tap()
        loginTextField.typeText("***@gmail.com")
        webView.swipeUp()
        
        // Проверяем наличие поля для пароля
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        
        // Вводим пароль
        passwordTextField.tap()
        passwordTextField.typeText("***")
        webView.swipeUp()
        
        // Нажимаем кнопку Login
        let loginButton = webView.buttons["Login"]
        XCTAssertTrue(loginButton.exists)
        loginButton.tap()
        
        // Ожидаем, пока лента или другой экран станет доступен после авторизации
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        
        // Проверяем, что первый элемент в таблице появился (это может быть индикатором успешной авторизации)
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
        
        // Также можно проверить наличие других элементов на экране, чтобы удостовериться, что авторизация прошла успешно
        let profileTabBarButton = app.tabBars.buttons["ProfileTabBarButton"]
        XCTAssertTrue(profileTabBarButton.exists)
    }
    
     func testFeed() throws {
        
        let feedTable = app.tables["FeedTableView"]
        XCTAssertTrue(feedTable.waitForExistence(timeout: 5), "Лента не загрузилась")
        
        // Скроллим вверх по экрану
        let firstCell = feedTable.cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.exists, "Первая ячейка ленты не найдена")
        firstCell.swipeUp()
        
        // Работа с кнопкой лайка
        let secondCell = feedTable.cells.element(boundBy: 1)
        XCTAssertTrue(secondCell.exists, "Вторая ячейка ленты не найдена")
        
        let likeButtonOff = secondCell.buttons["LikeButton"]
        XCTAssertTrue(feedTable.waitForExistence(timeout: 5), "Кнопка 'лайк выключен' не найдена")
        likeButtonOff.tap() // Ставим лайк
        
        let likeButtonOn = secondCell.buttons["LikeButton"]
        XCTAssertTrue(likeButtonOn.exists, "Кнопка 'лайк включен' не найдена")
        likeButtonOn.tap() // Отменяем лайк
        
        // Нажимаем на вторую ячейку, чтобы открыть картинку на весь экран
        secondCell.tap()
        
        // Проверяем, что картинка открылась
        let fullScreenImage = app.scrollViews.images.element(boundBy: 0)
        XCTAssertTrue(fullScreenImage.waitForExistence(timeout: 5), "Картинка не открылась на весь экран")
        
        // Увеличиваем картинку
        fullScreenImage.pinch(withScale: 3.0, velocity: 1.0)
        
        // Уменьшаем картинку
        fullScreenImage.pinch(withScale: 0.5, velocity: -1.0)
        
        // Возвращаемся на экран ленты
        let backButton = app.buttons["BackButton"]
        XCTAssertTrue(backButton.exists, "Кнопка возврата не найдена")
        backButton.tap()
    }
    
     func testProfile() throws {
        // Ожидаем, пока откроется экран с лентой
        let feedTabBarButton = app.tabBars.buttons["ImagesListTabBarButton"]
        XCTAssertTrue(feedTabBarButton.exists)
        feedTabBarButton.tap()
        
        // Ждем, пока откроется экран профиля
        let profileTabBarButton = app.tabBars.buttons["ProfileTabBarButton"]
        XCTAssertTrue(profileTabBarButton.exists)
        profileTabBarButton.tap()
        
        // Проверяем, что на экране отображаются персональные данные
        let nameLabel = app.staticTexts["profileNameLabel"]
        XCTAssertTrue(nameLabel.waitForExistence(timeout: 5)) // Ждем появления
        let usernameLabel = app.staticTexts["profileIDLabel"]
        XCTAssertTrue(usernameLabel.waitForExistence(timeout: 5)) // Ждем появления
        
        // Нажимаем кнопку логаута
        let logoutButton = app.buttons["logoutButton"]
        XCTAssertTrue(logoutButton.exists)
        logoutButton.tap()
        
        // Подтверждаем выход
        let logoutAlert = app.alerts["Пока-пока!"]
        XCTAssertTrue(logoutAlert.waitForExistence(timeout: 5)) // Ждем появления алерта
        logoutAlert.scrollViews.otherElements.buttons["LogoutYesButton"].tap()
        
        //Проверяем наличие экрана авторизации
        let loginButton = app.buttons["LoginButton"]
        XCTAssertTrue(loginButton.waitForExistence(timeout: 5), "Кнопка входа не найдена")
    }
    
    
    
}
