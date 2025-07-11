<template>
  <div id="app">
    <div class="recipe-container">
      <h1>楽天レシピ カテゴリ別ランキング</h1>
      <div class="category-buttons">
        <button v-for="category in categories" :key="category.id" @click="getRanking(category.id)">
          {{ category.name }}
        </button>
      </div>

      <div v-if="loading" class="loading">読込中...</div>
      <div v-if="error" class="error-message">{{ error }}</div>

      <div v-if="recipes.length > 0" class="results-grid">
        <div v-for="(recipe, index) in recipes" :key="recipe.recipeId" class="recipe-card">
          <div class="rank">{{ index + 1 }}位</div>
          <img :src="recipe.foodImageUrl" :alt="recipe.recipeTitle" />
          <h3>{{ recipe.recipeTitle }}</h3>
          <p class="description">{{ recipe.recipeDescription }}</p>
          <a :href="recipe.recipeUrl" target="_blank" rel="noopener noreferrer">作り方を見る</a>
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

const getRanking = async (categoryId: string) => {
  loading.value = true;
  error.value = '';
  recipes.value = [];

  try {
    // 自分たちのバックエンドAPI(/api/recipe-ranking)を呼び出す
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
</script>

<style>
/* 省略: スタイルは後ほど自由に追加してください */
</style>