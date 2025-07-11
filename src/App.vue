<template>
  <div id="app">
    <div class="recipe-container">
      <h1>楽天レシピ カテゴリ別ランキング</h1>

      <!-- カテゴリ選択UI -->
      <div class="category-selector">
        <!-- 大カテゴリ選択 -->
        <div class="select-wrapper">
          <select v-model="selectedLargeCategory" @change="onLargeCategoryChange">
            <option disabled value="">大カテゴリを選択</option>
            <option v-for="cat in largeCategories" :key="cat.categoryId" :value="cat.categoryId">
              {{ cat.categoryName }}
            </option>
          </select>
        </div>
        <!-- 中カテゴリ選択 -->
        <div class="select-wrapper">
          <select v-model="selectedMediumCategory" @change="getRanking" :disabled="!selectedLargeCategory">
            <option disabled value="">中カテゴリを選択</option>
            <option v-for="cat in mediumCategoriesToShow" :key="cat.categoryId" :value="cat.categoryId">
              {{ cat.categoryName }}
            </option>
          </select>
        </div>
      </div>

      <div v-if="loading" class="loading-spinner"></div>
      <div v-if="error" class="error-message">{{ error }}</div>

      <div v-if="!loading && recipes.length === 0 && !error" class="no-results">
        <p>カテゴリを選択して、ランキングを表示してください。</p>
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
import { ref, onMounted, computed } from 'vue';

// 型定義
interface Category {
  categoryId: string;
  categoryName: string;
  parentCategoryId?: string;
}

// リアクティブなState
const largeCategories = ref<Category[]>([]);
const mediumCategories = ref<Category[]>([]);
const selectedLargeCategory = ref('');
const selectedMediumCategory = ref('');

const recipes = ref<any[]>([]);
const loading = ref(false);
const error = ref('');

// 中カテゴリの絞り込み
const mediumCategoriesToShow = computed(() => {
  if (!selectedLargeCategory.value) return [];
  return mediumCategories.value.filter(cat => cat.parentCategoryId === selectedLargeCategory.value);
});

// 大カテゴリが変更された時の処理
const onLargeCategoryChange = () => {
  selectedMediumCategory.value = ''; // 中カテゴリの選択をリセット
  recipes.value = []; // ランキング表示をクリア
  error.value = ''; // エラーメッセージをクリア
};

// カテゴリ一覧を取得する関数
const fetchCategories = async () => {
  try {
    const response = await fetch('/api/get-categories');
    const data = await response.json();
    if (response.ok) {
      largeCategories.value = data.large;
      mediumCategories.value = data.medium;
    } else {
      error.value = 'カテゴリ一覧の取得に失敗しました。';
    }
  } catch (e) {
    error.value = 'カテゴリ一覧の取得中に通信エラーが発生しました。';
  }
};

// ランキングを取得する関数
const getRanking = async () => {
  const largeCatId = selectedLargeCategory.value;
  const mediumCatId = selectedMediumCategory.value;

  // 両方のカテゴリが選択されていることを確認
  if (!largeCatId || !mediumCatId) return;

  // ★★★ 修正点: 正しいカテゴリIDの形式（親-子）を組み立てる ★★★
  const categoryId = `${largeCatId}-${mediumCatId}`;

  loading.value = true;
  error.value = '';
  recipes.value = [];

  try {
    const response = await fetch(`/api/recipe-ranking?categoryId=${categoryId}`);
    const data = await response.json();

    if (response.ok) {
      // 楽天APIはstatus 200でも、結果がない場合にerrorフィールドを含むことがある
      if (data.error) {
         error.value = data.error_description || `カテゴリ「${categoryId}」のランキングが見つかりませんでした。`;
      } else {
         recipes.value = data.result;
      }
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

// コンポーネントがマウントされた時にカテゴリ一覧を取得
onMounted(fetchCategories);
</script>

<style>
:root {
  --primary-color: #BF0000;
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

.category-selector {
  display: flex;
  justify-content: center;
  flex-wrap: wrap;
  gap: 1rem;
  margin-bottom: 2rem;
}

.select-wrapper {
  position: relative;
  width: 250px;
}

.select-wrapper::after {
  content: '▼';
  font-size: 0.8rem;
  position: absolute;
  right: 1rem;
  top: 50%;
  transform: translateY(-50%);
  pointer-events: none;
}

.select-wrapper select {
  width: 100%;
  padding: 0.75rem 2.5rem 0.75rem 1rem;
  border: 1px solid var(--border-color);
  border-radius: 8px;
  background-color: var(--card-background-color);
  font-size: 1rem;
  cursor: pointer;
  appearance: none; /* ブラウザ標準の矢印を消す */
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
