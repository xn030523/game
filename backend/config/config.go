package config

import (
	"database/sql"
	"log"
	"os"
	"path/filepath"
	"strings"

	"github.com/joho/godotenv"
	_ "github.com/go-sql-driver/mysql"
	"gorm.io/driver/mysql"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

var DB *gorm.DB

type Config struct {
	DBHost     string
	DBPort     string
	DBUser     string
	DBPassword string
	DBName     string
	JWTSecret  string
	ServerPort string
}

var AppConfig *Config

func Load() {
	// 加载 .env 文件
	if err := godotenv.Load(); err != nil {
		log.Println("未找到 .env 文件，使用环境变量或默认值")
	}

	AppConfig = &Config{
		DBHost:     getEnv("DB_HOST", "127.0.0.1"),
		DBPort:     getEnv("DB_PORT", "3306"),
		DBUser:     getEnv("DB_USER", "root"),
		DBPassword: getEnv("DB_PASSWORD", ""),
		DBName:     getEnv("DB_NAME", "farm_game"),
		JWTSecret:  getEnv("JWT_SECRET", "farm-game-secret-key"),
		ServerPort: getEnv("SERVER_PORT", "8080"),
	}
}

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}

func InitDB() {
	// 先连接MySQL（不指定数据库），创建数据库
	createDatabase()

	// 再连接到指定数据库
	dsn := AppConfig.DBUser + ":" + AppConfig.DBPassword + "@tcp(" + AppConfig.DBHost + ":" + AppConfig.DBPort + ")/" + AppConfig.DBName + "?charset=utf8mb4&parseTime=True&loc=Local&multiStatements=true"

	var err error
	DB, err = gorm.Open(mysql.Open(dsn), &gorm.Config{
		Logger: logger.Default.LogMode(logger.Warn),
	})
	if err != nil {
		log.Fatal("数据库连接失败:", err)
	}
	log.Println("数据库连接成功")

	// 检查并初始化表
	initTables()
}

// createDatabase 创建数据库（如果不存在）
func createDatabase() {
	dsn := AppConfig.DBUser + ":" + AppConfig.DBPassword + "@tcp(" + AppConfig.DBHost + ":" + AppConfig.DBPort + ")/?charset=utf8mb4&parseTime=True&loc=Local"
	
	db, err := sql.Open("mysql", dsn)
	if err != nil {
		log.Fatal("连接MySQL失败:", err)
	}
	defer db.Close()

	_, err = db.Exec("CREATE DATABASE IF NOT EXISTS " + AppConfig.DBName + " DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci")
	if err != nil {
		log.Fatal("创建数据库失败:", err)
	}
	log.Println("数据库检查/创建完成:", AppConfig.DBName)
}

// initTables 初始化表结构和数据
func initTables() {
	// 检查 users 表是否存在
	var count int64
	DB.Raw("SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = ? AND table_name = 'users'", AppConfig.DBName).Scan(&count)

	if count == 0 {
		log.Println("检测到数据库为空，开始初始化...")
		
		// 执行完整 SQL 文件
		if err := execSQLFile("sql/farm_game_full.sql"); err != nil {
			log.Fatal("执行 farm_game_full.sql 失败:", err)
		}
		log.Println("数据库初始化完成")
	} else {
		log.Println("数据库表已存在，跳过初始化")
	}
}

// execSQLFile 执行 SQL 文件
func execSQLFile(filename string) error {
	// 获取可执行文件所在目录
	execPath, _ := os.Executable()
	execDir := filepath.Dir(execPath)
	
	// 尝试多个路径
	paths := []string{
		filename,
		filepath.Join(execDir, filename),
		filepath.Join(".", filename),
	}

	var content []byte
	var err error
	for _, path := range paths {
		content, err = os.ReadFile(path)
		if err == nil {
			log.Printf("读取SQL文件: %s", path)
			break
		}
	}
	if err != nil {
		return err
	}

	// 使用原生 SQL 连接执行（支持多语句）
	sqlDB, err := DB.DB()
	if err != nil {
		return err
	}

	// 移除注释并执行
	sqlContent := string(content)
	// 移除单行注释
	lines := strings.Split(sqlContent, "\n")
	var cleanLines []string
	for _, line := range lines {
		trimmed := strings.TrimSpace(line)
		if !strings.HasPrefix(trimmed, "--") {
			cleanLines = append(cleanLines, line)
		}
	}
	sqlContent = strings.Join(cleanLines, "\n")

	_, err = sqlDB.Exec(sqlContent)
	if err != nil {
		log.Printf("SQL执行错误: %v", err)
		return err
	}
	return nil
}

func GetDB() *gorm.DB {
	return DB
}
