# Blog  
Name  

**Blog Server**  

**Summary**  
This will be a project to show how to build a blog website. This should have quite a fe w steps and require a lot of knowledge of the Phoenix library as well as Ecto.  

Once done you should be able to: add tags, create a comment, add a cover image, as well as create a blog.  

**Technologies**  
Phoenix  
Elixir  

**Contributors**  
Me  
Let me know if you want to contribute  

**Diagram**  
The overall project should follow this structure.  
```mermaid
erDiagram
User {
  string username
  string email
  string password
  string hashed_password
  naive_datetime confirmed_at
}

Post {
    string title
    text content
    date published_on
    boolean visibility
}

CoverImage {
    text url
    id post_id
}

Comment {
  text content
  id post_id
}

Tag {
    string name
}

User |O--O{ Post: ""
Post }O--O{ Tag: ""
Post ||--O{ Comment: ""
Post ||--|| CoverImage: ""
```