{
  programs.git = {
    settings = {
      user.name = "Teamofeyy";
      user.email = "timarnd06@gmail.com";
    };

    includes = [
      {
        condition = "gitdir:~/work/**/";
        contents.user = {
          name = "Тимофей Марченко";
          email = "t.marchenko@madrigal.expert";
        };
      }
      {
        condition = "gitdir:~/personal/**/";
        contents.user = {
          name = "Teamofeyy";
          email = "timarnd06@gmail.com";
        };
      }
    ];
  };
}
