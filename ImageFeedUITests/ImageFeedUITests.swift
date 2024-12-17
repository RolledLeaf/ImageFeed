import XCTest

class Image_FeedUITests: XCTestCase {
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
        loginTextField.typeText("your email")
        webView.swipeUp()
        
        // Проверяем наличие поля для пароля
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        
        // Вводим пароль
        passwordTextField.tap()
        passwordTextField.typeText("your password")
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
        XCTAssertTrue(firstCell.isHittable, "Первая ячейка не доступна")
        
        feedTable.swipeUp()  // Прокручиваем еще
        sleep(1)  // Небольшая задержка для предотвращения быстрой прокрутки
        
        // Работа с кнопкой лайка
        let secondCell = feedTable.cells.element(boundBy: 1)
        XCTAssertTrue(secondCell.waitForExistence(timeout: 5), "Вторая ячейка не появилась вовремя")
        XCTAssertTrue(secondCell.exists, "Вторая ячейка ленты не найдена")
        secondCell.swipeUp() // Прокрутите до ячейки, если требуется
        XCTAssertTrue(secondCell.isHittable, "Вторая ячейка недоступна для взаимодействия")
        
        let likeButton = secondCell.buttons["LikeButton"]
        XCTAssertTrue(likeButton.waitForExistence(timeout: 5), "Кнопка 'лайк' не появилась")
        XCTAssertTrue(likeButton.frame != .zero, "Кнопка 'лайк' имеет нулевую область")
        XCTAssertTrue(likeButton.exists, "Кнопка 'лайк выключен' не найдена")
        XCTAssertTrue(likeButton.isHittable, "Кнопка 'лайк' недоступна для взаимодействия")
        likeButton.tap() // Ставим лайк
        sleep(UInt32(1.2))
        likeButton.tap() // Снимаем
        
        
        // Нажимаем на вторую ячейку, чтобы открыть картинку на весь экран
        secondCell.tap()
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
    }
}
