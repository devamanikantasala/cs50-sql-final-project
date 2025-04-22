from cs50 import SQL
database = SQL("sqlite:///dont-panic.db");
passcode = input("Enter the password: ");
database.execute("""
    UPDATE "users"
    SET "password" = ?
    WHERE "username" = 'admin';
""",passcode);
print("Hacked!")
