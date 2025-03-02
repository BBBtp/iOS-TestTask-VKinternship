/// Модель отзыва.
struct Review: Decodable {
    
    /// Текст отзыва.
    let text: String
    /// Время создания отзыва.
    let created: String
    /// Имя пользователя.
    let firstName: String
    /// Фамилия пользователя.
    let lastName: String
    /// Рейтинг отзыва.
    let rating: Int
    /// Аватар пользователя
    let avatar: String
    /// Фото отзыва
    let photos: [String]
    enum CodingKeys: String, CodingKey {
        case text
        case created
        case firstName = "first_name"
        case lastName = "last_name"
        case rating
        case avatar = "avatar_url"
        case photos = "photo_urls"
    }
    
}
