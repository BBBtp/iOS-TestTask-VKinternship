/// Модель отзыва.
struct Review: Decodable {
    
    /// Текст отзыва.
    let text: String
    /// Время создания отзыва.
    let created: String
    /// Имя пользователя
    let firstName: String
    /// Фамилия пользователя
    let lastName: String

    enum CodingKeys: String, CodingKey {
        case text
        case created
        case firstName = "first_name"
        case lastName = "last_name"
    }
    
}
