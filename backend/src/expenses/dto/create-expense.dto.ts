import {
  IsEnum,
  IsDateString,
  IsPositive,
  IsOptional,
  IsString,
  IsInt,
  ValidateIf,
  IsNotEmpty,
} from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { ExpenseCategory } from '../expense.entity';

export class CreateExpenseDto {
  @ApiPropertyOptional({ example: 1 })
  @IsOptional()
  @IsInt()
  @IsPositive()
  ownerId?: number;

  @ApiProperty({ example: '2026-04-10' })
  @IsDateString()
  date: string;

  @ApiProperty({ enum: ExpenseCategory, example: ExpenseCategory.MEDICINE })
  @IsEnum(ExpenseCategory)
  category: ExpenseCategory;

  @ApiPropertyOptional({ example: 'Transport' })
  @ValidateIf((o) => o.category === ExpenseCategory.OTHER)
  @IsString()
  @IsNotEmpty()
  customCategory?: string;

  @ApiProperty({ example: 1500 })
  @IsPositive()
  amount: number;

  @ApiPropertyOptional({ example: 'Antibiotic treatment' })
  @IsOptional()
  @IsString()
  note?: string;
}
