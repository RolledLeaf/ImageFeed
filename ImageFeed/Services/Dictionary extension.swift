import Foundation

extension Dictionary where Key == String, Value == String {
    func percentEncoded() -> Data? {
        // Преобразование в массив пар "ключ=значение"
        let parameterArray = self.map { "\($0)=\($1)" }
        // Соединение пар с символом '&' и кодирование в Data
        let parameterString = parameterArray.joined(separator: "&")
        return parameterString.data(using: .utf8)
    }
}
