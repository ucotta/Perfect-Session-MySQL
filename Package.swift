import PackageDescription

#if os(OSX)
let package = Package(
     name: "SessionMySQL",
     targets: [],
     dependencies: [
          .Package(url: "https://github.com/ucotta/MySQL-ConnectionPool.git", majorVersion: 0, minor: 20),
          .Package(url: "https://github.com/PerfectlySoft/Perfect-HTTP.git", majorVersion: 2, minor: 0),
          .Package(url: "https://github.com/PerfectlySoft/Perfect-mysqlclient.git", majorVersion: 2, minor: 0)
     ],
     exclude: []
)
#else
let package = Package(
     name: "SessionMySQL",
     targets: [],
     dependencies: [
          .Package(url: "https://github.com/ucotta/MySQL-ConnectionPool.git", majorVersion: 0, minor: 20),
          .Package(url: "https://github.com/PerfectlySoft/Perfect-HTTP.git", majorVersion: 2, minor: 0),
          .Package(url: "https://github.com/PerfectlySoft/Perfect-mysqlclient-Linux.git", majorVersion: 2, minor: 0)
     ],
     exclude: []
)
#endif
