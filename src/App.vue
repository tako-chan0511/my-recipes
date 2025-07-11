<template>
  <div id="app">
    <div class="recipe-container">
      <h1>楽天レシピ カテゴリ別ランキング</h1>
      <div class="category-buttons">
        <button 
          v-for="category in categories" 
          :key="category.id" 
          @click="getRanking(category.id)"
          :class="{ active: activeCategoryId === category.id }"
        >
          {{ category.name }}
        </button>
      </div>

      <!-- ローディング表示をスピナーに変更 -->
      <div v-if="loading" class="loading-spinner"></div>
      
      <div v-if="error" class="error-message">{{ error }}</div>

      <div v-if="!loading && recipes.length === 0 && !error" class="no-results">
        <p>カテゴリを選択してください。</p>
      </div>

      <div class="results-grid">
        <div v-for="(recipe, index) in recipes" :key="recipe.recipeId" class="recipe-card">
          <div class="rank">{{ index + 1 }}位</div>
          <img :src="recipe.foodImageUrl" :alt="recipe.recipeTitle" @error="onImageError" />
          <div class="card-content">
            <h3>{{ recipe.recipeTitle }}</h3>
            <p class="description">{{ recipe.recipeDescription }}</p>
            <a :href="recipe.recipeUrl" target="_blank" rel="noopener noreferrer" class="recipe-link">作り方を見る</a>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';

// レシピカテゴリの定義
const categories = [
  { id: '30', name: '豚肉' },
  { id: '31', name: '鶏肉' },
  { id: '32', name: '牛肉' },
  { id: '14', name: 'パスタ' },
  { id: '22', name: 'カレー' },
];

const recipes = ref<any[]>([]);
const loading = ref(false);
const error = ref('');
const activeCategoryId = ref<string | null>(null);

const getRanking = async (categoryId: string) => {
  loading.value = true;
  error.value = '';
  recipes.value = [];
  activeCategoryId.value = categoryId;

  try {
    const response = await fetch(`/api/recipe-ranking?categoryId=${categoryId}`);
    const data = await response.json();

    if (response.ok) {
      recipes.value = data.result;
    } else {
      error.value = data.error_description || 'ランキングの取得に失敗しました。';
    }
  } catch (e) {
    error.value = '通信エラーが発生しました。';
  } finally {
    loading.value = false;
  }
};

// 画像の読み込みに失敗した場合の代替処理
const onImageError = (event: Event) => {
  (event.target as HTMLImageElement).src = 'https://placehold.co/300x300/eee/ccc?text=No+Image';
};
</script>

<style>
:root {
  --primary-color: #BF0000; /* 楽天のブランドカラー */
  --background-color: #f7f7f7;
  --card-background-color: #ffffff;
  --text-color: #333333;
  --sub-text-color: #666666;
  --border-color: #e0e0e0;
}

body {
  font-family: 'Helvetica Neue', Arial, 'Hiragino Kaku Gothic ProN', 'Hiragino Sans', Meiryo, sans-serif;
  margin: 0;
  background-color: var(--background-color);
  color: var(--text-color);
}

#app {
  padding: 2rem;
}

.recipe-container {
  max-width: 1200px;
  margin: 0 auto;
}

h1 {
  text-align: center;
  color: var(--primary-color);
  margin-bottom: 2rem;
}

.category-buttons {
  display: flex;
  justify-content: center;
  flex-wrap: wrap;
  gap: 1rem;
  margin-bottom: 2rem;
}

.category-buttons button {
  padding: 0.75rem 1.5rem;
  border: 1px solid var(--border-color);
  border-radius: 2rem;
  background-color: var(--card-background-color);
  color: var(--text-color);
  font-size: 1rem;
  cursor: pointer;
  transition: all 0.2s ease-in-out;
}

.category-buttons button:hover {
  background-color: #f0f0f0;
  border-color: #ccc;
}

.category-buttons button.active {
  background-color: var(--primary-color);
  color: white;
  border-color: var(--primary-color);
}

.loading-spinner {
  border: 4px solid rgba(0, 0, 0, 0.1);
  width: 36px;
  height: 36px;
  border-radius: 50%;
  border-left-color: var(--primary-color);
  margin: 2rem auto;
  animation: spin 1s ease infinite;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.error-message, .no-results {
  text-align: center;
  padding: 2rem;
  margin: 2rem 0;
  background-color: var(--card-background-color);
  border-radius: 8px;
  color: var(--sub-text-color);
}

.results-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 1.5rem;
}

.recipe-card {
  background-color: var(--card-background-color);
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
  transition: transform 0.2s ease-in-out, box-shadow 0.2s ease-in-out;
  display: flex;
  flex-direction: column;
  position: relative;
}

.recipe-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 8px 20px rgba(0, 0, 0, 0.12);
}

.recipe-card .rank {
  position: absolute;
  top: 0;
  left: 0;
  background-color: var(--primary-color);
  color: white;
  padding: 0.5rem 1rem;
  font-weight: bold;
  border-radius: 12px 0 8px 0;
}

.recipe-card img {
  width: 100%;
  height: 200px;
  object-fit: cover;
}

.card-content {
  padding: 1.5rem;
  flex-grow: 1;
  display: flex;
  flex-direction: column;
}

.card-content h3 {
  margin: 0 0 0.5rem 0;
  font-size: 1.2rem;
}

.card-content .description {
  font-size: 0.9rem;
  color: var(--sub-text-color);
  flex-grow: 1;
  margin-bottom: 1rem;
}

.recipe-link {
  display: inline-block;
  text-align: center;
  padding: 0.75rem;
  background-color: var(--primary-color);
  color: white;
  text-decoration: none;
  border-radius: 8px;
  transition: background-color 0.2s;
}

.recipe-link:hover {
  background-color: #A60000;
}
</style>
