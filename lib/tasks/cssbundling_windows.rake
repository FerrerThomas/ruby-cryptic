# cssbundling-rails detecta yarn con `command -v`, que no existe en Windows,
# y entonces `bin/rails test` falla. En Windows lo buscamos con `where`.
if Gem.win_platform?
  Cssbundling::Tasks.module_eval do
    private

    def tool_exists?(tool)
      system("where #{tool}", out: File::NULL, err: File::NULL)
    end
  end
end
