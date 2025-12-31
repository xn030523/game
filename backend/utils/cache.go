package utils

import (
	"sync"
	"time"
)

type CacheItem struct {
	Value      interface{}
	ExpireAt   time.Time
}

type Cache struct {
	items map[string]CacheItem
	mu    sync.RWMutex
}

var GlobalCache = NewCache()

func NewCache() *Cache {
	c := &Cache{
		items: make(map[string]CacheItem),
	}
	go c.cleanupLoop()
	return c
}

func (c *Cache) Set(key string, value interface{}, ttl time.Duration) {
	c.mu.Lock()
	defer c.mu.Unlock()
	c.items[key] = CacheItem{
		Value:    value,
		ExpireAt: time.Now().Add(ttl),
	}
}

func (c *Cache) Get(key string) (interface{}, bool) {
	c.mu.RLock()
	defer c.mu.RUnlock()
	item, ok := c.items[key]
	if !ok || time.Now().After(item.ExpireAt) {
		return nil, false
	}
	return item.Value, true
}

func (c *Cache) Delete(key string) {
	c.mu.Lock()
	defer c.mu.Unlock()
	delete(c.items, key)
}

func (c *Cache) DeletePrefix(prefix string) {
	c.mu.Lock()
	defer c.mu.Unlock()
	for k := range c.items {
		if len(k) >= len(prefix) && k[:len(prefix)] == prefix {
			delete(c.items, k)
		}
	}
}

func (c *Cache) cleanupLoop() {
	ticker := time.NewTicker(5 * time.Minute)
	for range ticker.C {
		c.mu.Lock()
		now := time.Now()
		for k, v := range c.items {
			if now.After(v.ExpireAt) {
				delete(c.items, k)
			}
		}
		c.mu.Unlock()
	}
}
