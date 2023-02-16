if which swiftlint > /dev/null && which swiftformat > /dev/null; then
  swiftformat .
  swiftlint --fix
else
  echo "warning: SwiftLint or SwiftFormat not installed, download from https://github.com/realm/SwiftLint and https://github.com/nicklockwood/SwiftFormat"
fi
