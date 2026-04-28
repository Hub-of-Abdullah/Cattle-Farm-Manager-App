import {
  IsInt,
  IsPositive,
  IsDateString,
  IsOptional,
  IsBoolean,
  IsString,
} from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateSaleDto {
  @ApiProperty({ example: 10 })
  @IsInt()
  @IsPositive()
  cattleId: number;

  @ApiProperty({ example: '2026-03-10' })
  @IsDateString()
  saleDate: string;

  @ApiProperty({ example: 70000 })
  @IsPositive()
  salePrice: number;

  @ApiPropertyOptional({ example: 'Karim' })
  @IsOptional()
  @IsString()
  buyerName?: string;

  @ApiPropertyOptional({ example: true, default: false })
  @IsOptional()
  @IsBoolean()
  addToFirmAccount?: boolean;

  @ApiPropertyOptional({ example: 70000 })
  @IsOptional()
  @IsPositive()
  firmAccountAmount?: number;
}
