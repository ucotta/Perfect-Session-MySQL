import PackageDescription

let package = Package(
     name: "SessionMySQL",
     targets: [],
     dependencies: [
          .Package(url: "https://github.com/ucotta/MySQL-ConnectionPool.git", majorVersion: 0),
          .Package(url: "https://github.com/PerfectlySoft/Perfect-HTTP.git", majorVersion: 2, minor: 0),
          .Package(url: "https://github.com/PerfectlySoft/Perfect-MySQL.git", majorVersion: 2, minor: 0),
     ],
     exclude: []
)



