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

      <!-- 高機能フィルター -->
      <div v-if="recipes.length > 0" class="additional-filters">
        <!-- 材料フィルター (プルダウン) -->
        <div class="filter-group">
          <label for="ingredient-filter">この材料を含む:</label>
          <select id="ingredient-filter" v-model="mustIncludeIngredient">
            <option value="">指定なし</option>
            <option v-for="ing in popularIngredients" :key="ing" :value="ing">{{ ing }}</option>
          </select>
        </div>
        <!-- 調理時間フィルター -->
        <div class="filter-group">
          <label for="time-filter">調理時間:</label>
          <select id="time-filter" v-model="timeFilter">
            <option value="">指定なし</option>
            <option value="10">10分以内</option>
            <option value="20">20分以内</option>
            <option value="30">30分以内</option>
          </select>
        </div>
      </div>
      
      <!-- こだわり条件フィルター -->
      <div v-if="recipes.length > 0" class="special-filters">
        <label class="filter-group-label">こだわり条件 (含まない材料):</label>
        <div class="checkbox-group">
          <div v-for="filter in exclusionFilters" :key="filter.id" class="checkbox-wrapper">
            <!-- ★★★ 変更: v-modelとvalueを修正 ★★★ -->
            <input type="checkbox" :id="filter.id" :value="filter.id" v-model="selectedExclusionIds" />
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
}

// --- 定数データ ---
const popularIngredients = ['卵', '牛乳', 'チーズ', '鶏肉', '豚肉', '牛肉', 'きのこ', 'トマト', '玉ねぎ'];
// ★★★ 変更: 複数のキーワードをチェックできるように改善 ★★★
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
// ★★★ 変更: 選択されたフィルターのIDを保持するように変更 ★★★
const selectedExclusionIds = ref<string[]>([]);

// --- Computed Properties ---
const mediumCategoriesToShow = computed(() => {
  if (!selectedLargeCategory.value) return [];
  return mediumCategories.value.filter(cat => cat.parentCategoryId === selectedLargeCategory.value);
});

const filteredRecipes = computed(() => {
  return recipes.value.filter(recipe => {
    // 1. 「この材料を含む」フィルターのチェック
    if (mustIncludeIngredient.value) {
      const query = mustIncludeIngredient.value.toLowerCase();
      if (!recipe.recipeMaterial.some(material => material.toLowerCase().includes(query))) {
        return false;
      }
    }

    // 2. 「調理時間」フィルターのチェック
    if (timeFilter.value) {
      const maxTime = parseInt(timeFilter.value, 10);
      const match = recipe.recipeIndication.match(/(\d+)/);
      if (match) {
        const recipeTime = parseInt(match[1], 10);
        if (recipeTime > maxTime) {
          return false;
        }
      }
    }

    // ★★★ 変更: 改善された「こだわり条件」のフィルターロジック ★★★
    if (selectedExclusionIds.value.length > 0) {
      // 選択されたフィルターIDに対応するキーワードをすべて取得
      const allExclusionKeywords = selectedExclusionIds.value.flatMap(id => 
        exclusionFilters.find(f => f.id === id)?.keywords || []
      );
      
      // 除外キーワードのいずれかが材料に含まれていたら、このレシピは除外 (false)
      if (allExclusionKeywords.some(exclusionKeyword => 
        recipe.recipeMaterial.some(material => material.toLowerCase().includes(exclusionKeyword.toLowerCase()))
      )) {
        return false;
      }
    }

    // 全てのフィルター条件を通過した場合のみ、このレシピを含める (true)
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
  // ★★★ 変更: selectedExclusionIdsをリセット ★★★
  selectedExclusionIds.value = [];

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
  gap: 2rem;
  padding: 1.5rem;
  background-color: var(--card-background-color);
  border-radius: 8px;
  margin-bottom: 1rem;
  box-shadow: 0 2px 8px rgba(0,0,0,0.05);
}

.filter-group {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
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
  width: 200px;
}

.special-filters {
  padding: 1.5rem;
  background-color: var(--card-background-color);
  border-radius: 8px;
  margin-bottom: 2rem;
  box-shadow: 0 2px 8px rgba(0,0,0,0.05);
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
