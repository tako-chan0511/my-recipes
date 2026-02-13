<template>
  <div id="app">
    <div class="recipe-container">
      <h1>楽天レシピ カテゴリ別ランキング</h1>

      <!-- カテゴリ選択UI -->
      <div class="category-selector">
        <div class="select-wrapper">
          <select v-model="selectedLargeCategory" @change="onLargeCategoryChange">
            <option disabled value="">大カテゴリを選択</option>
            <option v-for="cat in largeCategories" :key="cat.categoryId" :value="cat.categoryId">
              {{ cat.categoryName }}
            </option>
          </select>
        </div>
        <div class="select-wrapper">
          <select v-model="selectedMediumCategory" @change="getRanking" :disabled="!selectedLargeCategory">
            <option disabled value="">中カテゴリを選択</option>
            <option v-for="cat in mediumCategoriesToShow" :key="cat.categoryId" :value="cat.categoryId">
              {{ cat.categoryName }}
            </option>
          </select>
        </div>
      </div>

      <!-- ★★★ 変更: フィルターUIをシンプルに ★★★ -->
      <div class="additional-filters" :class="{ disabled: recipes.length === 0 }">
        <div class="filter-group">
          <label for="ingredient-filter">この材料を含む:</label>
          <select id="ingredient-filter" v-model="mustIncludeIngredient" :disabled="recipes.length === 0">
            <option value="">指定なし</option>
            <option v-for="ing in popularIngredients" :key="ing" :value="ing">{{ ing }}</option>
          </select>
        </div>
        <div class="filter-group">
          <label for="time-filter">調理時間:</label>
          <select id="time-filter" v-model="timeFilter" :disabled="recipes.length === 0">
            <option value="">指定なし</option>
            <option value="10">10分以内</option>
            <option value="20">20分以内</option>
            <option value="30">30分以内</option>
          </select>
        </div>
      </div>
      
      <div class="special-filters" :class="{ disabled: recipes.length === 0 }">
        <label class="filter-group-label">こだわり条件 (含まない材料):</label>
        <div class="checkbox-group">
          <div v-for="filter in exclusionFilters" :key="filter.id" class="checkbox-wrapper">
            <input type="checkbox" :id="filter.id" :value="filter.id" v-model="selectedExclusionIds" :disabled="recipes.length === 0" />
            <label :for="filter.id">{{ filter.label }}</label>
          </div>
        </div>
      </div>


      <div v-if="loading" class="loading-spinner"></div>
      <div v-if="error" class="error-message">{{ error }}</div>
      
      <div v-if="!loading && filteredRecipes.length === 0 && !error" class="no-results">
        <p>表示するレシピがありません。<br>カテゴリを選択するか、フィルター条件を変更してください。</p>
      </div>

      <div class="results-grid">
        <div v-for="(recipe, index) in filteredRecipes" :key="recipe.recipeId" class="recipe-card">
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

// --- 型定義 ---
interface Category {
  categoryId: string;
  categoryName: string;
  parentCategoryId?: string;
}
interface Recipe {
  recipeId: number;
  foodImageUrl: string;
  recipeTitle: string;
  recipeDescription: string;
  recipeUrl: string;
  recipeMaterial: string[];
  recipeIndication: string;
  recipeCost: string;
  calories: string;
}

// --- 定数データ ---
const popularIngredients = ['卵', '牛乳', 'チーズ', '鶏肉', '豚肉', '牛肉', 'きのこ', 'トマト', '玉ねぎ'];
const exclusionFilters = [
  { id: 'exclude-egg', label: '卵アレルギー対応', keywords: ['卵', 'たまご', 'egg'] },
  { id: 'exclude-milk', label: '乳製品アレルギー対応', keywords: ['牛乳', 'ミルク', 'チーズ', 'バター', 'ヨーグルト', '生クリーム', '乳', 'milk', 'cheese', 'butter', 'yogurt', 'cream'] },
  { id: 'exclude-pork', label: '豚肉不使用 (ハラル等)', keywords: ['豚', 'ポーク', 'pork'] },
];

// --- リアクティブなState ---
const largeCategories = ref<Category[]>([]);
const mediumCategories = ref<Category[]>([]);
const selectedLargeCategory = ref('');
const selectedMediumCategory = ref('');

const recipes = ref<Recipe[]>([]);
const loading = ref(false);
const error = ref('');

const mustIncludeIngredient = ref('');
const timeFilter = ref('');
const selectedExclusionIds = ref<string[]>([]);

// ★★★ 削除: カロリーと値段のStateを削除 ★★★
// const calorieFilter = ref(2000);
// const costFilter = ref(3000);

// ★★★ 改善: 文字列から最大値を取得するヘルパー関数 ★★★
const getMaxNumberFromString = (str: string): number | null => {
  if (!str || typeof str !== 'string') {
    return null;
  }
  const normalizedStr = str
    .replace(/[０-９，～－]/g, s => String.fromCharCode(s.charCodeAt(0) - 0xFEE0))
    .replace(/,/g, '');
  
  const numbers = normalizedStr.match(/\d+/g);
  if (!numbers) {
    return null;
  }
  
  const numericValues = numbers.map(n => parseInt(n, 10));
  return Math.max(...numericValues);
};


// --- Computed Properties ---
const mediumCategoriesToShow = computed(() => {
  if (!selectedLargeCategory.value) return [];
  return mediumCategories.value.filter(cat => cat.parentCategoryId === selectedLargeCategory.value);
});

const filteredRecipes = computed(() => {
  return recipes.value.filter(recipe => {
    // 材料フィルター
    if (mustIncludeIngredient.value) {
      const query = mustIncludeIngredient.value.toLowerCase();
      if (!recipe.recipeMaterial.some(material => material.toLowerCase().includes(query))) return false;
    }

    // 調理時間フィルター
    if (timeFilter.value) {
      const maxTime = parseInt(timeFilter.value, 10);
      const recipeTime = getMaxNumberFromString(recipe.recipeIndication);
      if (recipeTime === null || recipeTime > maxTime) return false;
    }
    
    // ★★★ 削除: カロリーと値段のフィルターロジックを削除 ★★★

    // こだわり条件フィルター
    if (selectedExclusionIds.value.length > 0) {
      const allExclusionKeywords = selectedExclusionIds.value.flatMap(id => 
        exclusionFilters.find(f => f.id === id)?.keywords || []
      );
      if (allExclusionKeywords.some(keyword => 
        recipe.recipeMaterial.some(material => material.toLowerCase().includes(keyword.toLowerCase()))
      )) {
        return false;
      }
    }

    return true;
  });
});

// --- Methods ---
const onLargeCategoryChange = () => {
  selectedMediumCategory.value = '';
  recipes.value = [];
  error.value = '';
};

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

const getRanking = async () => {
  const categoryId = `${selectedLargeCategory.value}-${selectedMediumCategory.value}`;
  if (!selectedLargeCategory.value || !selectedMediumCategory.value) return;

  loading.value = true;
  error.value = '';
  recipes.value = [];
  // フィルターをリセット
  mustIncludeIngredient.value = '';
  timeFilter.value = '';
  selectedExclusionIds.value = [];
  // ★★★ 削除: カロリーと値段のリセット処理を削除 ★★★

  try {
    const response = await fetch(`/api/recipe-ranking?categoryId=${categoryId}`);
    const data = await response.json();
    if (response.ok && !data.error) {
      recipes.value = data.result;
    } else {
      error.value = data.error_description || `カテゴリ「${categoryId}」のランキングが見つかりませんでした。`;
    }
  } catch (e) {
    error.value = '通信エラーが発生しました。';
  } finally {
    loading.value = false;
  }
};

const onImageError = (event: Event) => {
  (event.target as HTMLImageElement).src = 'https://placehold.co/300x300/eee/ccc?text=No+Image';
};

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
  appearance: none;
}

.additional-filters {
  display: flex;
  justify-content: center;
  flex-wrap: wrap; /* 折り返しを許可 */
  gap: 2rem;
  padding: 1.5rem;
  background-color: var(--card-background-color);
  border-radius: 8px;
  margin-bottom: 1rem;
  box-shadow: 0 2px 8px rgba(0,0,0,0.05);
  transition: opacity 0.3s;
}

.additional-filters.disabled,
.special-filters.disabled {
  opacity: 0.5;
  pointer-events: none;
}

.filter-group {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  min-width: 200px;
}

.filter-group label {
  font-weight: bold;
  font-size: 0.9rem;
}

.filter-group input,
.filter-group select {
  padding: 0.5rem;
  border: 1px solid var(--border-color);
  border-radius: 4px;
  font-size: 1rem;
  width: 100%;
}

.special-filters {
  padding: 1.5rem;
  background-color: var(--card-background-color);
  border-radius: 8px;
  margin-bottom: 2rem;
  box-shadow: 0 2px 8px rgba(0,0,0,0.05);
  transition: opacity 0.3s;
}
.filter-group-label {
  font-weight: bold;
  font-size: 0.9rem;
  display: block;
  margin-bottom: 1rem;
}
.checkbox-group {
  display: flex;
  gap: 1.5rem;
  flex-wrap: wrap;
}
.checkbox-wrapper {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}
.checkbox-wrapper input[type="checkbox"] {
  width: 1.2em;
  height: 1.2em;
  cursor: pointer;
}
.checkbox-wrapper label {
  cursor: pointer;
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
