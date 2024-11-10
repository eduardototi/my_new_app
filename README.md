# JetRocks - Ruby Test Task

The Ruby Test Task application was developed as part of a technical test for the Web Developer position at JetRocks. The primary goal was to demonstrate my skills in Ruby on Rails, as well as my ability to build a functional and well-structured application within a limited timeframe.

## Description

The application allows users to:

- Creating a post
- Allow a user to rate a post
- List all IPs with users
- List posts with the best ratings

This project was designed to be simple yet functional, showcasing my understanding of software development best practices.

## Technologies Used

This project uses the following technologies:

- **Ruby 3.3.0 and Rails 7.2.2** 
- **PostgreSQL** 

## Installation

1. Clone the repository:
   ```bash
    git clone git@github.com:eduardototi/my_new_app.git
    cd my_new_app
2. Install dependencies:
   ```bash
    bundle install
3. Configure the `.env` file:
   - Create a `.env` file in the root of the project and add your environment variables.
   - Example of the `.env` file:
   ```bash
    touch .env

    NEW_APP_DATABASE_USERNAME=your_database_username
    NEW_APP_DATABASE_PASSWORD=your_database_password
    NEW_APP_DATABASE_HOST=localhost
4. Configure DB:
   ```bash
    rails db:create
    rails db:migrate 
    rails db:seed
5. Tests cases:
   ```bash
    bundle exec rspec -f d
    open coverage/index.html  # This can be used to view the test coverage of the application.
## API Endpoints

The application exposes the following API endpoints:

### 1. **POST api/v1/posts**
- **Description**: Create a new post.
- **Example Request using `curl`**:
    To rate a post:
    ```bash
    curl --location 'http://localhost:3000/api/v1/posts' \
      --header 'Content-Type: application/json' \
      --data '{
          "user": {
              "login": "john_doe"
          },
          "title": "Meu titulo",
          "ip":"123.456",
          "body": "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean vestibulum quam cursus pharetra vehicula. Aliquam euismod sodales scelerisque. Aenean aliquam, justo sit amet fermentum sagittis, quam ipsum lobortis velit, quis feugiat sem lore faucibus metus. Cras aliquam posuere metus, elementum ultricies ipsum eleifend a. Vivamus sagittis diam eu nisi euismod tincidunt. Cras non felis tortor. Maecenas aliquam dui dui, sed vulputate erat venenatis in."

      }'
    ```
- **Request Body**:
    ```json
    {
      "user": {
          "login": "john_doe"
      },
        "title": "Meu titulo",
        "ip":"123.456",
        "body": "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean vestibulum quam cursus pharetra vehicula. Aliquam euismod sodales scelerisque. Aenean aliquam, justo sit amet fermentum sagittis, quam ipsum lobortis velit, quis feugiat sem lore faucibus metus. Cras aliquam posuere metus, elementum ultricies ipsum eleifend a. Vivamus sagittis diam eu nisi euismod tincidunt. Cras non felis tortor. Maecenas aliquam dui dui, sed vulputate erat venenatis in."
    }
    ```
- **Response**: Returns the created post.
    ```json
    {
      "posts": {
          "id": "7ab55ed9-eb33-47e1-a796-c11a981c1371",
          "user_id": "463cefb4-d6ab-4ddd-864a-300b367e1832",
          "title": "Meu titulo",
          "body": "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean vestibulum quam cursus pharetra vehicula. Aliquam euismod sodales scelerisque. Aenean aliquam, justo sit amet fermentum sagittis, quam ipsum lobortis velit, quis feugiat sem lore faucibus metus. Cras aliquam posuere metus, elementum ultricies ipsum eleifend a. Vivamus sagittis diam eu nisi euismod tincidunt. Cras non felis tortor. Maecenas aliquam dui dui, sed vulputate erat venenatis in.",
          "ip": "123.456",
          "created_at": "2024-11-10T12:54:28.077Z",
          "updated_at": "2024-11-10T12:54:28.077Z"
      }
  }
    ```

### 2. **POST api/v1/ratings/**
- **Description**: Allow a user to rate a post.
- **Example Request using `curl`**:
    To rate a post:
    ```bash
    curl --location 'http://localhost:3000/api/v1/ratings' \
      --header 'Content-Type: application/json' \
      --data '{
          "post_id": "ff76bfb1-6c68-40d7-ad6b-7215514368be",
          "user_id": "fd1cb3d0-e48f-4ece-8b1d-1c43755ae500",
          "value": 5
      }'
    ```
- **Request Body**:
    ```json
    {
      "post_id": "ff76bfb1-6c68-40d7-ad6b-7215514368be",
      "user_id": "fd1cb3d0-e48f-4ece-8b1d-1c43755ae500",
      "value": 5
    }
    ```
- **Response**: Returns the rating with post average rating.
    ```json
    {
        "post_id": "fffff649-dee0-492d-827f-57b8fdbe4fe4",
        "average_rating": 3
    }
    ```

### 3. **GET /api/v1/posts/ips_list**
- **Description**: Retrieve all IPs associated with users.
- **Example Request using `curl`**:
    To get the ips list:
    ```bash
    curl --location 'http://localhost:3000/api/v1/posts/ips_list'
    ```
- **Response**:
    ```json
   [
      {
          "ip": "105.58.220.212",
          "author_logins": [
              "amiee_pacocha",
              "antoinette_durgan",
              "anton.ernser",
              "benny",
              "blake.murphy",
              "buster.bartell",
              "diego_heidenreich",
              "dusty",
              "frida",
              "inocencia",
              "issac",
              "jarrod.heathcote",
              "jerald_grady",
              "kelley.quitzon",
              "kelli.denesik",
              "larraine",
              "leonel",
              "lincoln",
              "mason",
              "orlando",
              "ricardo.damore",
              "rosalba.blanda",
              "sergio",
              "shantay_schaden",
              "shirly",
              "valorie.okuneva"
          ]
      }
### 4. **GET /posts/top_rated_posts?n=5**
- **Description**: List posts with the best ratings. By default, this endpoint will return the top 10 rated posts. You can modify the number of posts returned by sending a query parameter `n` with the desired number of posts.
  
- **Query Parameter**:
        - `n`: The number of top-rated posts to return. If not provided, it defaults to 10.

- **Example Request using `curl`**:
    To get the top 5 rated posts:
    ```bash
    curl --location 'http://localhost:3000/api/v1/posts/top_rated_posts?n=5'
    ```
    This will return the top 5 rated posts.

    To get the default 10 top-rated posts (without specifying `n`):
    ```bash
    curl --location 'http://localhost:3000/api/v1/posts/top_rated_posts'
    ```

- **Response**:
    ```json
    {
      "posts": [
          {
              "id": "ff37d850-3767-41fb-b8d6-28d63cdc9f8e",
              "title": "Perspiciatis voluptas consectetur.",
              "body": "Soluta officia eos. Ipsa adipisci non. Accusamus doloribus nobis.",
              "average_rating": 5
          },
          {
              "id": "a77a974b-bf0a-4eba-a6aa-a44a8eebaadb",
              "title": "Et cupiditate reprehenderit.",
              "body": "Quae aut maiores. Quia quod est. Doloribus omnis vel.",
              "average_rating": 4
          },
          {
              "id": "e357406a-25b0-44da-95da-af329b2f2d31",
              "title": "Illo rem ratione.",
              "body": "Omnis qui sapiente. Recusandae porro maxime. Voluptate illum ut.",
              "average_rating": 3
          },
          {
              "id": "4d54ee20-344d-4e1b-9700-afe318ab99f7",
              "title": "Doloremque deserunt et.",
              "body": "Asperiores maiores qui. Porro perspiciatis sint. Dolores possimus harum.",
              "average_rating": 2
          },
          {
              "id": "e3b9a05c-3802-49ef-88cb-90b720e6822e",
              "title": "Dignissimos autem maxime.",
              "body": "Reprehenderit rerum dolorum. Sapiente ut est. Nisi earum architecto.",
              "average_rating": 1
          }
      ]
  }
    ```


    


## Gems Used

This project uses the following gems:

- **`parallel`**: A gem that provides simple parallel processing for Ruby, allowing you to run tasks concurrently, which can speed up operations that are CPU-bound or require parallel execution.
  
- **`dotenv-rails`**: Loads environment variables from `.env` files into the Rails application for development and testing environments. It's useful for managing configuration settings without hardcoding them into your codebase.

- **`pry-rails`**: An enhanced version of the Ruby interactive shell (Pry), providing advanced debugging and introspection capabilities. It integrates with Rails for easy debugging and inspection during development.

- **`rubocop-rails`**: A RuboCop extension for Rails, used to enforce style and coding standards for Ruby on Rails applications. It helps to ensure code consistency and readability.

- **`rspec-rails`**: A gem that provides RSpec support for Rails applications, enabling behavior-driven development (BDD) for testing. It allows writing tests in a readable and expressive way, making it easier to verify the behavior of the application.

- **`factory_bot_rails`**: A gem used to define test data factories for creating objects in tests. It allows for easy and flexible creation of test objects, reducing boilerplate code in test setup.

- **`shoulda-matchers`**: A gem that provides additional matchers for RSpec and Minitest, making it easier to write concise and readable tests. It adds support for testing common Rails functionality like validations, associations, and more.

- **`faker`**: A gem for generating fake data, such as names, addresses, emails, and more. It's useful for seeding databases or generating realistic data for testing purposes.


